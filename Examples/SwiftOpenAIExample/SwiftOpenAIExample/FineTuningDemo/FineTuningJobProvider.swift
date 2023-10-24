//
//  FineTuningJobProvider.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftUI
import SwiftOpenAI

@Observable class FineTuningJobProvider {
   
   var createdFineTuningJob: FineTuningJobObject? = nil
   var canceledFineTuningJob: FineTuningJobObject? = nil
   var retrievedFineTuningJob: FineTuningJobObject? = nil
   var fineTunedJobs: [FineTuningJobObject] = []
   var finteTuningEventObjects: [FineTuningJobEventObject] = []
   
   private let service: OpenAIService

   init(service: OpenAIService) {
      self.service = service
   }
   
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
}
