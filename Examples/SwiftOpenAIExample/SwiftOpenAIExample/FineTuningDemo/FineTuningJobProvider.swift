//
//  FineTuningJobProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftOpenAI
import SwiftUI

@Observable
class FineTuningJobProvider {
  init(service: OpenAIService) {
    self.service = service
  }

  var createdFineTuningJob: FineTuningJobObject?
  var canceledFineTuningJob: FineTuningJobObject?
  var retrievedFineTuningJob: FineTuningJobObject?
  var fineTunedJobs: [FineTuningJobObject] = []
  var finteTuningEventObjects: [FineTuningJobEventObject] = []

  func createFineTuningJob(
    parameters: FineTuningJobParameters)
    async throws
  {
    createdFineTuningJob = try await service.createFineTuningJob(parameters: parameters)
  }

  func listFineTuningJobs()
    async throws
  {
    fineTunedJobs = try await service.listFineTuningJobs(after: nil, limit: nil).data
  }

  func retrieveFineTuningJob(
    id: String)
    async throws
  {
    retrievedFineTuningJob = try await service.retrieveFineTuningJob(id: id)
  }

  func cancelFineTuningJob(
    id: String)
    async throws
  {
    canceledFineTuningJob = try await service.cancelFineTuningJobWith(id: id)
  }

  func listFineTuningEventsForJobWith(
    id: String)
    async throws
  {
    finteTuningEventObjects = try await service.listFineTuningEventsForJobWith(id: id, after: nil, limit: nil).data
  }

  private let service: OpenAIService
}
