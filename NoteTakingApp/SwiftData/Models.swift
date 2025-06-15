import Foundation
import SwiftData


// MARK: - Persistence Service
@MainActor
class PersistenceService {
    static let shared = PersistenceService()
    private var modelContainer: ModelContainer
    
    private init() {
        do {
            modelContainer = try ModelContainer(for: Note.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    // Create
    func createNote(title: String, content: String) -> Note {
        let note = Note(title: title, content: content)
        context.insert(note)
        save()
        return note
    }
    
    // Read
    func fetchNotes() -> [Note] {
        do {
            let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
    
    // Update
    func updateNote(_ note: Note, title: String, content: String) {
        note.title = title
        note.content = content
        note.updatedAt = Date()
        save()
    }
    
    // Delete
    func deleteNote(_ note: Note) {
        context.delete(note)
        save()
    }
    
    // Save context
    private func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 
