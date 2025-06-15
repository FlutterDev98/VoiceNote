import Foundation
import SwiftUI
import SwiftData

@MainActor
class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    private let persistenceService = PersistenceService.shared
    
    init() {
        loadNotes()
    }
    
    func loadNotes() {
        notes = persistenceService.fetchNotes()
    }
    
    func addNote(title: String, content: String) {
        let note = persistenceService.createNote(title: title, content: content)
        notes.insert(note, at: 0)
    }
    
    func updateNote(_ note: Note, title: String, content: String) {
        persistenceService.updateNote(note, title: title, content: content)
        loadNotes() // Reload to maintain order
    }
    
    func deleteNote(_ note: Note) {
        persistenceService.deleteNote(note)
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
        }
    }
} 