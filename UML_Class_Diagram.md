# Class Diagram - VoiceNote

classDiagram
    class NoteModel {
        +UUID id
        +String title
        +String content
        +URL? audioURL
        +String transcription
        +String translatedContent
        +Date createdAt
        +Date updatedAt
        +init()
        +updateNote()
        +deleteNote()
    }
    
    class NoteViewModel {
        +[NoteModel] notes
        +String searchText
        +NoteModel? selectedNote
        +Bool isLoading
        +String errorMessage
        +fetchNotes()
        +addNote(title: String, content: String)
        +updateNote(note: NoteModel)
        +deleteNote(note: NoteModel)
        +searchNotes(query: String)
        +saveNote()
    }
    
    class WhisperService {
        +String serverURL
        +URLSession session
        +transcribeAudio(audioURL: URL) String
        +detectLanguage(audioURL: URL) String
        +parseTranscriptionResponse(data: Data) String
        +handleError(error: Error) String
    }
    
    class NLTitleGenerator {
        +String generateTitle(content: String) String
        +String extractKeywords(text: String) [String]
    }
    
    class NoteListView {
        +NoteViewModel viewModel
        +Bool showingNewNote
        +Bool showingRecordView
        +onAppear()
        +onDelete(offsets: IndexSet)
        +onTap(note: NoteModel)
    }
    
    class DetailView {
        +NoteModel note
        +Bool isPlaying
        +AVAudioPlayer? audioPlayer
        +onAppear()
        +playAudio()
        +stopAudio()
        +deleteNote()
    }
    
    class NewNoteView {
        +String title
        +String content
        +Bool isRecording
        +AVAudioRecorder? recorder
        +onSave()
        +onRecord()
        +onStop()
        +onCancel()
    }
    
    class RecordView {
        +Bool isRecording
        +AVAudioRecorder? recorder
        +String audioURL
        +onRecord()
        +onStop()
        +onSave()
        +onCancel()
    }
    
    class ContentView {
        +NoteViewModel viewModel
        +onAppear()
    }
    
    class VoiceNote {
        +ModelContainer modelContainer
        +init()
    }
    
    %% Relationships
    NoteViewModel --> NoteModel : manages
    NoteListView --> NoteViewModel : uses
    DetailView --> NoteModel : displays
    NewNoteView --> NoteViewModel : updates
    RecordView --> WhisperService : uses
    ContentView --> NoteViewModel : uses
    VoiceNote --> NoteModel : contains
    
    %% Service relationships
    WhisperService --> NoteModel : updates transcription
    NLTitleGenerator --> NoteModel : generates title
    
    %% View relationships
    NoteListView --> NewNoteView : presents
    NoteListView --> RecordView : presents
    NoteListView --> DetailView : navigates to
    
    %% Data flow
    NoteModel ||--o{ NoteViewModel : "1 to many"
    NoteViewModel ||--|| NoteListView : "1 to 1"
    NoteViewModel ||--|| DetailView : "1 to 1"
    NoteViewModel ||--|| NewNoteView : "1 to 1"
```

## Class Descriptions

### Data Models

**NoteModel**
- Core data entity representing a note
- Contains all note-related information including audio and transcription
- Managed by SwiftData for persistence

**NoteViewModel**
- Business logic layer for note management
- Handles CRUD operations and search functionality
- Manages application state and data flow

### Services

**WhisperService**
- Handles communication with local Whisper server
- Manages audio transcription and language detection
- Provides error handling for transcription failures

**NLTitleGenerator**
- Generates titles for notes based on content
- Extracts keywords for better note organization
- Uses natural language processing techniques

### Views

**NoteListView**
- Main interface showing all notes
- Handles note selection and navigation
- Provides search and filtering capabilities

**DetailView**
- Displays individual note details
- Manages audio playback functionality
- Handles note editing and deletion

**NewNoteView**
- Interface for creating new notes
- Supports both text and audio input
- Manages recording state and audio capture

**RecordView**
- Dedicated audio recording interface
- Handles audio capture and processing
- Integrates with transcription service

**ContentView**
- Root view of the application
- Manages overall app state and navigation

**VoiceNote**
- Main application entry point
- Configures SwiftData and app environment 