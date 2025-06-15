import Foundation
import AVFoundation
import os.log
import NaturalLanguage

class WhisperService: ObservableObject {
    @Published var isTranscribing = false
    @Published var transcriptionProgress: Double = 0.0
    
    static let shared = WhisperService()
    private let baseURL = "http://localhost:9000"
    private let session: URLSession
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.notetakingapp", category: "WhisperService")
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300 // 5 minutes
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func transcribeAudio(fileURL: URL) async throws -> String {
        isTranscribing = true
        transcriptionProgress = 0.0
        
        defer {
            isTranscribing = false
            transcriptionProgress = 1.0
        }
        
        // Create a multipart form request
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: baseURL + "/transcribe")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        // Append file data
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        data.append(try Data(contentsOf: fileURL))
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        // Send the request
        let (responseData, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "WhisperService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
        
        let transcriptionResponse = try JSONDecoder().decode(TranscriptionResponse.self, from: responseData)
        return transcriptionResponse.text
    }
}

struct TranscriptionResponse: Codable {
    let text: String
}

struct TranslationRequest: Codable {
    let text: String
}

struct TranslationResponse: Codable {
    let translatedText: String
} 