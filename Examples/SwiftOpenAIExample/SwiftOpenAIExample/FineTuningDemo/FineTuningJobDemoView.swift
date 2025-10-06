//
//  FineTuningJobDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/23/23.
//

import SwiftOpenAI
import SwiftUI

// MARK: - FineTuningJobDemoView

struct FineTuningJobDemoView: View {
  init(service: OpenAIService) {
    _fineTuningJobProvider = State(initialValue: FineTuningJobProvider(service: service))
  }

  var body: some View {
    VStack {
      Button("List Fine tuning jobs") {
        Task {
          isLoading = true
          defer { isLoading = false } // ensure isLoading is set to false when the
          try await fineTuningJobProvider.listFineTuningJobs()
        }
      }
      .buttonStyle(.borderedProminent)
      List {
        ForEach(Array(fineTuningJobProvider.fineTunedJobs.enumerated()), id: \.offset) { _, job in
          FineTuningObjectView(job: job)
        }
      }
    }
    .overlay(
      Group {
        if isLoading {
          ProgressView()
        } else {
          EmptyView()
        }
      })
  }

  @State private var fineTuningJobProvider: FineTuningJobProvider
  @State private var isLoading = false
}

// MARK: - FineTuningObjectView

struct FineTuningObjectView: View {
  init(job: FineTuningJobObject) {
    self.job = job
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Fine Tuned Model - \(job.fineTunedModel ?? "NO MODEL")")
        .font(.title2)
      VStack(alignment: .leading, spacing: 2) {
        Text("Model = \(job.model)")
        Text("Object = \(job.object)")
        Text("ID = \(job.id)")
        Text("Created = \(job.createdAt)")
        Text("Organization ID = \(job.organizationId)")
        Text("Training file = \(job.trainingFile)")
        Text("Status = \(job.status)")
          .bold()
      }
      .font(.callout)
    }
    .foregroundColor(.primary)
    .padding()
    .background(
      RoundedRectangle(cornerSize: .init(width: 20, height: 20))
        .foregroundColor(.mint))
  }

  private let job: FineTuningJobObject
}
