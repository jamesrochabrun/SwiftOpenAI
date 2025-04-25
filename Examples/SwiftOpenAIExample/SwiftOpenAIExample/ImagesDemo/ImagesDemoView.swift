import SwiftUI
import SwiftOpenAI

struct ImagesDemoView: View {
    enum ImageModel: String, CaseIterable, Identifiable {
        case gptImage1 = "GPT-Image-1"
        case dallE3 = "DALL-E 3"
        case dallE2 = "DALL-E 2"
        
        var id: String { self.rawValue }
        
        var model: CreateImageParameters.Model {
            switch self {
            case .gptImage1: return .gptImage1
            case .dallE3: return .dallE3
            case .dallE2: return .dallE2
            }
        }
    }
    
    enum ImageQuality: String, CaseIterable, Identifiable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        case standard = "Standard"
        case hd = "HD"
        
        var id: String { self.rawValue }
        
        var quality: CreateImageParameters.Quality {
            switch self {
            case .high: return .high
            case .medium: return .medium
            case .low: return .low
            case .standard: return .standard
            case .hd: return .hd
            }
        }
    }
    
    @State private var imagesProvider: ImagesProvider
    @State private var isLoading = false
    @State private var prompt = ""
    @State private var errorMessage = ""
    @State private var selectedModel: ImageModel = .gptImage1
    @State private var selectedQuality: ImageQuality = .high
    @State private var selectedSize = "1024x1024"
    @State private var imageCount = 1
    @State private var isAdvancedOptionsExpanded = false
    @State private var isShowingBase64Images = false
    
    init(service: OpenAIService) {
        _imagesProvider = State(initialValue: ImagesProvider(service: service))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("OpenAI Image Generation")
                    .font(.title)
                    .padding(.top)
                
                // Prompt input area
                promptInputArea
                
                // Advanced options (collapsible)
                advancedOptionsArea
                
                // Generate button
                generateButton
                
                // Error message
                if !errorMessage.isEmpty {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .bold()
                        .padding()
                }
                
                // Images display
                imageResultsArea
            }
            .padding()
        }
        .overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.4)
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Text("Generating images...")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.7)))
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
        )
    }
    
    private var promptInputArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter a prompt")
                .font(.headline)
            
            TextField("Describe what you want to generate...", text: $prompt, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .padding(.bottom, 8)
        }
    }
    
    private var advancedOptionsArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isAdvancedOptionsExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Advanced Options")
                        .font(.headline)
                    Spacer()
                    Image(systemName: isAdvancedOptionsExpanded ? "chevron.up" : "chevron.down")
                        .animation(.default, value: isAdvancedOptionsExpanded)
                }
            }
            .foregroundColor(.primary)
            
            if isAdvancedOptionsExpanded {
                VStack(spacing: 16) {
                    // Model picker
                    HStack {
                        Text("Model:")
                            .frame(width: 100, alignment: .leading)
                        
                        Picker("Select Model", selection: $selectedModel) {
                            ForEach(ImageModel.allCases) { model in
                                Text(model.rawValue).tag(model)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Quality picker
                    HStack {
                        Text("Quality:")
                            .frame(width: 100, alignment: .leading)
                        
                        Picker("Select Quality", selection: $selectedQuality) {
                            ForEach(ImageQuality.allCases) { quality in
                                Text(quality.rawValue).tag(quality)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Size picker
                    HStack {
                        Text("Size:")
                            .frame(width: 100, alignment: .leading)
                        
                        Picker("Select Size", selection: $selectedSize) {
                            Text("1024x1024").tag("1024x1024")
                            Text("1536x1024").tag("1536x1024")
                            Text("1024x1536").tag("1024x1536")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Image count stepper
                    HStack {
                        Text("Count:")
                            .frame(width: 100, alignment: .leading)
                        
                        Stepper("\(imageCount) \(imageCount == 1 ? "image" : "images")", value: $imageCount, in: 1...4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var generateButton: some View {
        Button {
            Task {
                await generateImages()
            }
        } label: {
            Text("Generate Images")
                .frame(maxWidth: .infinity)
                .padding()
                .background(prompt.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(prompt.isEmpty || isLoading)
    }
    
    private var imageResultsArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !imagesProvider.images.isEmpty || !imagesProvider.base64Images.isEmpty {
                HStack {
                    Text("Generated Images")
                        .font(.headline)
                    Spacer()
                    
                    if !imagesProvider.base64Images.isEmpty {
                        Button {
                            isShowingBase64Images.toggle()
                        } label: {
                            Text(isShowingBase64Images ? "Show URL images" : "Show base64 images")
                                .font(.caption)
                        }
                    }
                }
                
                if isShowingBase64Images {
                    // Display base64 images
                    let uiImages = imagesProvider.getUIImagesFromBase64()
                    
                    if uiImages.isEmpty {
                        Text("No base64 images available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(Array(uiImages.enumerated()), id: \.offset) { index, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 5)
                            }
                        }
                    }
                } else {
                    // Display URL images
                    if imagesProvider.images.isEmpty {
                        Text("No URL images available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(Array(imagesProvider.images.enumerated()), id: \.offset) { index, url in
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    case .failure:
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.largeTitle)
                                            .frame(height: 200)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .shadow(radius: 5)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func generateImages() async {
        guard !prompt.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let parameters = CreateImageParameters(
                prompt: prompt,
                model: selectedModel.model,
                n: imageCount,
              //  quality: selectedQuality.quality,
                size: selectedSize
            )
            
            try await imagesProvider.createImages(parameters: parameters)
            
            // If we got base64 images but no URL images, automatically show base64 images
            if imagesProvider.images.isEmpty && !imagesProvider.base64Images.isEmpty {
                isShowingBase64Images = true
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
