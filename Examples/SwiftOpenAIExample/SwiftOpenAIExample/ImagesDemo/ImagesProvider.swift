import SwiftUI
import SwiftOpenAI

@Observable class ImagesProvider {
    
    let service: OpenAIService
    
    var images: [URL] = []
    var base64Images: [String] = [] // Store base64 encoded images
    
    init(service: OpenAIService) {
        self.service = service
    }
    
    // MARK: - New API Methods
    
    func createImages(
        parameters: CreateImageParameters)
        async throws
    {
        let response = try await service.createImages(parameters: parameters)
        processImageData(response.data)
    }
    
    func editImages(
        parameters: CreateImageEditParameters)
        async throws
    {
        let response = try await service.editImage(parameters: parameters)
        processImageData(response.data)
    }
    
    func createImageVariations(
        parameters: CreateImageVariationParameters)
        async throws
    {
        let response = try await service.createImageVariations(parameters: parameters)
        processImageData(response.data)
    }
    
    // Helper method to process the image data
    private func processImageData(_ imageDataArray: [CreateImageResponse]) {
        // Clear previous results
        self.images = []
        self.base64Images = []
        
        // Process each image data item
        for imageData in imageDataArray {
           for data in imageData.data {
               // If there's a URL, add it
               if let urlString = data.url, let url = URL(string: urlString) {
                   self.images.append(url)
               }
               
               // If there's base64 data, add it
               if let base64Data = data.b64JSON {
                   self.base64Images.append(base64Data)
               }
           }
        }
    }
    
    // MARK: - Base64 Helper Methods
    
    func getUIImagesFromBase64() -> [UIImage] {
        return base64Images.compactMap { base64String in
            guard let imageData = Data(base64Encoded: base64String) else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    // MARK: - Legacy API Methods
    
    func legacyCreateImages(
        parameters: ImageCreateParameters)
        async throws
    {
//        let urls = try await service.legacyCreateImages(
//            parameters: parameters).data.compactMap { $0.url }
//        self.images = urls.compactMap { URL(string: $0) }
    }
    
    func legacyEditImages(
        parameters: ImageEditParameters)
        async throws
    {
//        let urls = try await service.legacyEditImage(
//            parameters: parameters).data.compactMap { $0.url }
//        self.images = urls.compactMap { URL(string: $0) }
    }
    
    func legacyCreateImageVariations(
        parameters: ImageVariationParameters)
        async throws
    {
//        let urls = try await service.legacyCreateImageVariations(
//            parameters: parameters).data.compactMap { $0.url }
//        self.images = urls.compactMap { URL(string: $0) }
    }
}
