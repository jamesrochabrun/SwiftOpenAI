#if os(macOS) && compiler(>=6.0)
import Foundation
import SwiftOpenAI
import Testing

@Suite("URLSession streaming", .timeLimit(.minutes(1)))
struct URLSessionStreamingTests {
  @Test("The Apple adapter preserves empty lines, CRLF, CR and split UTF-8")
  func lineBoundaries() async throws {
    let server = try await StreamingLoopbackServer()
    defer { server.stop() }
    let session = URLSession(configuration: .ephemeral)
    defer { session.invalidateAndCancel() }
    let adapter = URLSessionHTTPClientAdapter(urlSession: session)
    let (body, _) = try await adapter.bytes(for: .init(
      url: server.url.appendingPathComponent("lines"),
      method: .get,
      headers: [:]))
    guard case .lines(let stream) = body else {
      Issue.record("Expected lines")
      return
    }
    var lines = [String]()
    for try await line in stream { lines.append(line) }
    #expect(lines == ["data: café 😀", "", "data: two", "", "tail"])
  }

  @Test("Responses decodes multiline events through the Apple adapter")
  func multilineResponse() async throws {
    let server = try await StreamingLoopbackServer()
    defer { server.stop() }
    let service = OpenAIServiceFactory.service(apiKey: "test", overrideBaseURL: server.url.absoluteString)
    let stream = try await service.responseCreateStream(.init(input: .string("multiline"), model: .custom("test")))
    var text = ""
    for try await event in stream {
      if case .outputTextDelta(let delta) = event { text += delta.delta }
    }
    #expect(text == "café 😀")
  }

  @Test("Cancelling one Responses consumer closes only its connection")
  func cancellationIsPerRequest() async throws {
    let server = try await StreamingLoopbackServer()
    defer { server.stop() }
    let session = URLSession(configuration: .ephemeral)
    defer { session.invalidateAndCancel() }
    let service = OpenAIServiceFactory.service(
      apiKey: "test", overrideBaseURL: server.url.absoluteString,
      httpClient: URLSessionHTTPClientAdapter(urlSession: session))
    func consume(_ name: String) async {
      do {
        let stream = try await service.responseCreateStream(.init(input: .string(name), model: .custom("test")))
        for try await _ in stream { }
      } catch { }
    }
    let first = Task { await consume("first") }
    let second = Task { await consume("second") }
    defer { first.cancel()
      second.cancel()
    }
    try #require(try await eventually {
      let state = try await server.snapshot()
      return state.frames["first", default: 0] >= 2 && state.frames["second", default: 0] >= 2
    })
    first.cancel()
    await first.value
    #expect(try await eventually { try await server.snapshot().closed["first"] == true })
    let before = try await server.snapshot()
    #expect(before.closed["second"] != true)
    #expect(try await eventually {
      try await server.snapshot().frames["second", default: 0] > before.frames["second", default: 0] + 2
    })
    #expect(await session.allTasks.filter { $0.state == .running }.count == 1)
    second.cancel()
    await second.value
    #expect(try await eventually { try await server.snapshot().closed["second"] == true })
    #expect(await eventually { await session.allTasks.isEmpty })
    let final = try await server.snapshot()
    #expect(final.requests == ["first": 1, "second": 1])
  }

  private func eventually(_ condition: () async throws -> Bool) async rethrows -> Bool {
    let deadline = ContinuousClock.now.advanced(by: .seconds(2))
    while ContinuousClock.now < deadline {
      if try await condition() { return true }
      try? await Task.sleep(for: .milliseconds(20))
    }
    return try await condition()
  }
}

private final class StreamingLoopbackServer {
  init() async throws {
    directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let script = directory.appendingPathComponent("server.py")
    try Self.source.write(to: script, atomically: true, encoding: .utf8)
    process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["python3", script.path]
    process.standardOutput = FileHandle.nullDevice
    process.standardError = FileHandle.nullDevice
    do {
      try process.run()
      let portFile = directory.appendingPathComponent("port")
      let deadline = ContinuousClock.now.advanced(by: .seconds(3))
      while ContinuousClock.now < deadline, process.isRunning {
        if let port = try? String(contentsOf: portFile, encoding: .utf8), let number = Int(port) {
          url = URL(string: "http://127.0.0.1:\(number)")!
          return
        }
        try await Task.sleep(for: .milliseconds(20))
      }
      throw URLError(.cannotConnectToHost)
    } catch {
      stop()
      throw error
    }
  }

  struct Snapshot: Decodable {
    let frames: [String: Int]
    let closed: [String: Bool]
    let requests: [String: Int]
  }

  private(set) var url = URL(string: "http://127.0.0.1")!

  func snapshot() async throws -> Snapshot {
    let (data, _) = try await URLSession.shared.data(from: url.appendingPathComponent("stats"))
    return try JSONDecoder().decode(Snapshot.self, from: data)
  }

  func stop() {
    if process.isRunning { process.terminate()
      process.waitUntilExit()
    }
    try? FileManager.default.removeItem(at: directory)
  }

  private static let source = #"""
    import json, threading, time
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
    from pathlib import Path

    state = {"frames": {}, "closed": {}, "requests": {}}
    lock = threading.Lock()

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args): pass

        def do_GET(self):
            if self.path == "/stats":
                with lock: body = json.dumps(state).encode()
            else:
                body = "data: café 😀\r\n\r\ndata: two\r\rtail".encode()
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            for byte in body:
                self.wfile.write(bytes([byte]))
                self.wfile.flush()

        def do_POST(self):
            request = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
            name = request["input"]
            with lock: state["requests"][name] = state["requests"].get(name, 0) + 1
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.end_headers()
            if name == "multiline":
                body = ('data: {"type":"response.output_text.delta",\r\n'
                        'data: "item_id":"m","output_index":0,"content_index":0,"delta":"café 😀"}\r\n\r\n'
                        'data: [DONE]\r\n\r\n')
                self.wfile.write(body.encode())
                return
            try:
                for _ in range(1000):
                    event = {"type": "response.output_text.delta", "item_id": "m",
                             "output_index": 0, "content_index": 0, "delta": "x"}
                    self.wfile.write(("data: " + json.dumps(event) + "\n\n").encode())
                    self.wfile.flush()
                    with lock: state["frames"][name] = state["frames"].get(name, 0) + 1
                    time.sleep(0.02)
            except (BrokenPipeError, ConnectionResetError):
                with lock: state["closed"][name] = True

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    Path(__file__).with_name("port").write_text(str(server.server_port))
    server.serve_forever()
    """#

  private let directory: URL
  private let process: Process

}
#endif
