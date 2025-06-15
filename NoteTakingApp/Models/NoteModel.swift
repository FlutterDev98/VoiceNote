import Foundation
import SwiftData

@Model
final class NoteModel {
    var title: String
    var content: String
    var createdAt: Date
    var audioFilePath: String?
    
    init(title: String, content: String, audioFilePath: String? = nil) {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.audioFilePath = audioFilePath
    }
} 