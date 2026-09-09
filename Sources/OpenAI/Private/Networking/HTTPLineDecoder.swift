import Foundation

// MARK: - HTTPLineDecoder

/// Incremental conversion of HTTP body chunks to lines.
struct HTTPLineDecoder {
  mutating func append(_ bytes: [UInt8]) -> [String] {
    var lines = [String]()
    for byte in bytes {
      if previousWasCR {
        previousWasCR = false
        if byte == 0x0A { continue }
      }
      if byte == 0x0A || byte == 0x0D {
        lines.append(String(decoding: pending, as: UTF8.self))
        pending.removeAll(keepingCapacity: true)
        previousWasCR = byte == 0x0D
      } else {
        pending.append(byte)
      }
    }
    return lines
  }

  mutating func finish() -> String? {
    guard !pending.isEmpty else { return nil }
    defer { pending.removeAll(keepingCapacity: true) }
    return String(decoding: pending, as: UTF8.self)
  }

  private var pending = [UInt8]()
  private var previousWasCR = false

}

// MARK: - HTTPLineStream

/// Owns the producer task so cancelling the line consumer also cancels the HTTP body.
enum HTTPLineStream {
  static func lines<Source: AsyncSequence>(from chunks: Source) -> AsyncThrowingStream<String, Error>
    where Source.Element == [UInt8]
  {
    AsyncThrowingStream { continuation in
      let task = Task {
        var decoder = HTTPLineDecoder()
        do {
          for try await chunk in chunks {
            try Task.checkCancellation()
            for line in decoder.append(chunk) {
              if case .terminated = continuation.yield(line) { return }
            }
          }
          try Task.checkCancellation()
          if let tail = decoder.finish() { continuation.yield(tail) }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }
}
