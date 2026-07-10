//
//  SwiftOpenAIExampleTests.swift
//  SwiftOpenAIExampleTests
//
//  Created by James Rochabrun on 10/19/23.
//

import XCTest
@testable import SwiftOpenAIExample

final class SwiftOpenAIExampleTests: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
  }

  func testRealtimeConversationReducesTranscriptDeltasIntoStableRows() {
    var conversation = RealtimeConversation()

    conversation.beginUserTurn(itemID: "user-1")
    conversation.appendUserTranscript("Hello", itemID: "user-1")
    conversation.appendUserTranscript(" there", itemID: "user-1")
    conversation.finishUserTranscript("Hello there", itemID: "user-1")

    XCTAssertEqual(conversation.entries.count, 1)
    XCTAssertEqual(conversation.entries[0].id, "user-1")
    XCTAssertEqual(conversation.entries[0].text, "Hello there")
    XCTAssertEqual(conversation.entries[0].state, .complete)
  }

  func testRealtimeConversationKeepsConcurrentAssistantItemsSeparate() {
    var conversation = RealtimeConversation()

    conversation.appendAssistantTranscript("First", itemID: "assistant-1", responseID: "response-1")
    conversation.appendAssistantTranscript("Second", itemID: "assistant-2", responseID: "response-1")
    conversation.finishAssistantTranscript("First answer", itemID: "assistant-1", responseID: "response-1")
    conversation.finishAssistantTranscript("Second answer", itemID: "assistant-2", responseID: "response-1")

    XCTAssertEqual(conversation.entries.map(\.id), ["assistant-1", "assistant-2"])
    XCTAssertEqual(conversation.entries.map(\.text), ["First answer", "Second answer"])
  }

  func testRealtimeConversationUsesServerOrdering() {
    var conversation = RealtimeConversation()
    conversation.appendUserText("First", itemID: "user-1")
    conversation.appendUserText("Third", itemID: "user-3")

    conversation.registerItem(
      itemID: "user-2",
      type: "message",
      role: "user",
      previousItemID: "user-1")
    conversation.finishUserTranscript("Second", itemID: "user-2")

    XCTAssertEqual(conversation.entries.map(\.id), ["user-1", "user-2", "user-3"])
  }

  func testRealtimeTurnCoordinatorKeepsMicOpenForBargeIn() {
    var coordinator = RealtimeTurnCoordinator()

    coordinator.sessionDidBecomeReady()
    XCTAssertTrue(coordinator.canStreamMicrophone)

    coordinator.responseDidStart()
    XCTAssertTrue(coordinator.canStreamMicrophone)

    _ = coordinator.responseDidFinish(responseID: nil, status: "completed")
    coordinator.playbackDrainDidStart()
    XCTAssertTrue(coordinator.canStreamMicrophone)

    coordinator.playbackDidFinish()
    XCTAssertTrue(coordinator.canStreamMicrophone)
  }

  func testRealtimeTurnCoordinatorContinuesOnlyCompletedMatchingToolResponse() {
    var coordinator = RealtimeTurnCoordinator()
    coordinator.sessionDidBecomeReady()
    coordinator.responseDidStart(responseID: "response-1")
    coordinator.toolOutputWasSent(responseID: "response-1")

    let unrelated = coordinator.responseDidFinish(responseID: "response-0", status: "cancelled")
    XCTAssertFalse(unrelated.didFinishCurrentResponse)
    XCTAssertFalse(unrelated.shouldCreateToolContinuation)

    let completed = coordinator.responseDidFinish(responseID: "response-1", status: "completed")
    XCTAssertTrue(completed.didFinishCurrentResponse)
    XCTAssertTrue(completed.shouldCreateToolContinuation)
  }

  func testRealtimeTurnCoordinatorDoesNotContinueCancelledToolResponse() {
    var coordinator = RealtimeTurnCoordinator()
    coordinator.sessionDidBecomeReady()
    coordinator.responseDidStart(responseID: "response-1")
    coordinator.toolOutputWasSent(responseID: "response-1")

    let completion = coordinator.responseDidFinish(responseID: "response-1", status: "cancelled")

    XCTAssertTrue(completion.didFinishCurrentResponse)
    XCTAssertFalse(completion.shouldCreateToolContinuation)
    XCTAssertTrue(coordinator.canStreamMicrophone)
    XCTAssertFalse(coordinator.isResponseInProgress)
  }

  func testRealtimeTurnCoordinatorIgnoresLateDuplicateCompletion() {
    var coordinator = RealtimeTurnCoordinator()
    coordinator.sessionDidBecomeReady()
    coordinator.responseDidStart(responseID: "response-1")
    _ = coordinator.responseDidFinish(responseID: "response-1", status: "completed")

    let duplicate = coordinator.responseDidFinish(responseID: "response-1", status: "completed")

    XCTAssertFalse(duplicate.didFinishCurrentResponse)
    XCTAssertFalse(duplicate.shouldCreateToolContinuation)
  }

  func testRealtimeMicrophoneGateOpensAndCloses() async {
    let gate = RealtimeMicrophoneGate()

    await gate.open()
    let isOpen = await gate.isOpen
    await gate.close()
    let isClosed = await !(gate.isOpen)

    XCTAssertTrue(isOpen)
    XCTAssertTrue(isClosed)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    measure {
      // Put the code you want to measure the time of here.
    }
  }
}
