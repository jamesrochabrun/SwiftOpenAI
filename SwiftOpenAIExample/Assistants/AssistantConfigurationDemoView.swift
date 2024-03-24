//
//  AssistantConfigurationDemoView.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 11/17/23.
//

import Foundation
import SwiftUI
import SwiftOpenAI

enum AssistantFunctionCallDefinition: String, CaseIterable {
   
   case createImage = "create_image"

   var functionTool: AssistantObject.Tool {
      switch self {
      case .createImage:
         return .init(type: .function, function: .init(
            name: self.rawValue,
            description: "call this function if the request asks to generate an image",
            parameters: .init(
               type: .object,
               properties: [
                  "prompt": .init(type: .string, description: "The exact prompt passed in."),
                  "count": .init(type: .integer, description: "The number of images requested")
               ],
               required: ["prompt", "count"])))
      }
   }
}

struct AssistantConfigurationDemoView: View {
   
   @State private var provider: AssistantConfigurationProvider
   @State private var parameters: AssistantParameters = AssistantParameters(action: .create(model: Model.gpt41106Preview.value))
   @State private var isAvatarLoading = false
   @State private var showAvatarFlow = false
   private let service: OpenAIService

   var isCodeInterpreterOn: Binding<Bool> {
       Binding(
           get: {
              let contains =
               self.parameters.tools.contains { $0.displayToolType == .codeInterpreter } == true
              return contains
           },
           set: { newValue in
               if newValue {
                  self.parameters.tools.append(AssistantObject.Tool(type: .codeInterpreter))
               } else {
                  self.parameters.tools.removeAll { $0.displayToolType == .codeInterpreter }
               }
           }
       )
   }
   
   var isDalleToolOn: Binding<Bool> {
       Binding(
           get: {
              let contains =
              self.parameters.tools.contains { $0.displayToolType == .function } == true
              return contains
           },
           set: { newValue in
               if newValue {
                  self.parameters.tools.append(AssistantFunctionCallDefinition.createImage.functionTool)
               } else {
                  self.parameters.tools.removeAll { $0.displayToolType == .function }
               }
           }
       )
   }
   
   init(service: OpenAIService) {
      self.service = service
      _provider = State(initialValue: AssistantConfigurationProvider(service: service))
   }
   
   var body: some View {
      ScrollView {
         VStack(spacing: 16) {
            avatarView
            inputViews
            capabilities
            footerActions
         }
         .padding()
      }.sheet(isPresented: $showAvatarFlow) {
         AssistantsListDemoView(assistants: provider.assistants, service: service)
      }
   }
   
   var footerActions: some View {
      HStack {
         Button("Save") {
            Task {
               try await provider.createAssistant(parameters: parameters)
            }
         }
         Button("Delete") {
            Task {
               for assistant in provider.assistants {
                  try await provider.deleteAssistant(id: assistant.id)
               }
            }
         }
         Button("Show Assistants") {
            Task {
               try await provider.listAssistants()
               showAvatarFlow = true
            }
         }
      }
      .buttonStyle(.borderedProminent)
   }
   
   @ViewBuilder
   var avatarView: some View {
      if isAvatarLoading {
         Circle()
            .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .frame(width: 100, height: 100)
            .overlay(
               Image(systemName: "rays")
                  .resizable()
                  .frame(width: 20, height: 20)
                  .tint(.gray)
                  .symbolEffect(.variableColor.iterative.dimInactiveLayers)
            )
      }
      else if let avatarURL = provider.avatarURL {
         URLImageView(url: avatarURL)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .shadow(radius: 10)
      } else {
         Circle()
            .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .frame(width: 100, height: 100)
            .overlay(
               Menu.init(content: {
                  Button {
                     Task {
                        isAvatarLoading = true
                        defer { isAvatarLoading = false }  // ensure isLoading is set to false when the
                        let prompt = parameters.description ?? "Some random image for an avatar"
                        try await provider.createAvatar(prompt: prompt)
                     }
                  }  label: {
                     Text("Use DALL·E")
                  }
               }, label: {
                  Image(systemName: "plus")
                     .resizable()
                     .frame(width: 20, height: 20)
                     .tint(.gray)
               })
            )
      }
   }
   
   var inputViews: some View {
      VStack(spacing: 16) {
         InputView(title: "Name") {
            TextField("", text: $parameters.name.orEmpty, axis: .vertical)
         }
         InputView(title: "Description") {
            TextField("", text: $parameters.description.orEmpty, axis: .vertical)
         }
         InputView(title: "Instructions") {
            ZStack {
               RoundedRectangle(cornerRadius: 4)
                  .stroke(.gray.opacity(0.3))
               TextEditor(text: $parameters.instructions.orEmpty)
                  .foregroundStyle(.primary)
                  .clipShape(RoundedRectangle(cornerRadius: 4))
                  .frame(minHeight: 100)
            }
         }
      }
      .textFieldStyle(.roundedBorder)
   }
   
   var capabilities: some View {
      InputView(title: "Capabilities") {
         VStack(spacing: 16) {
            CheckboxRow(title: "Code interpreter", isChecked: isCodeInterpreterOn)
            CheckboxRow(title: "DALL·E Image Generation", isChecked: isDalleToolOn)
         }
      }
      .inputViewStyle(.init(verticalPadding: 16.0))
   }
}

extension Binding where Value == String? {
    var orEmpty: Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0 }
        )
    }
}

#Preview {
   AssistantConfigurationDemoView(service: OpenAIServiceFactory.service(apiKey: ""))
}


// MARK: InputView

struct InputView<Content: View>: View {
   
   let content: Content
   let title: String
   
   init(title: String, @ViewBuilder content: () -> Content) {
      self.title = title
      self.content = content()
   }
   
   var body: some View {
      VStack(alignment: .leading, spacing: style.verticalPadding) {
         Text(title)
            .font(.headline)
         content
      }
   }
   
   @Environment(\.inputViewStyle) private var style: InputViewStyle

}

struct InputViewStyle {
   
   let verticalPadding: CGFloat
   
   init(verticalPadding: CGFloat = 8.0) {
      self.verticalPadding = verticalPadding
   }
}

struct InputViewStyleKey: EnvironmentKey {
    static let defaultValue = InputViewStyle()
}

extension EnvironmentValues {
    var inputViewStyle: InputViewStyle {
        get { self[InputViewStyleKey.self] }
        set { self[InputViewStyleKey.self] = newValue }
    }
}

extension View {
    func inputViewStyle(_ style: InputViewStyle) -> some View {
        environment(\.inputViewStyle, style)
    }
}

struct CheckboxView: View {
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: {
           withAnimation {
              isChecked.toggle()
           }
        }) {
            Image(systemName: isChecked ? "checkmark.square" : "square")
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CheckboxRow: View {
   
   let title: String
   @Binding var isChecked: Bool

   var body: some View {
      HStack {
         CheckboxView(isChecked: $isChecked)
         Text(title)
         Spacer()
      }
   }
}
