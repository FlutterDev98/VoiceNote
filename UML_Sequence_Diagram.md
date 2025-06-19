# Sequence Diagram - VoiceNote

## Audio Note Creation with Transcription Flow

```mermaid
sequenceDiagram
    participant U as User
    participant NV as NoteListView
    participant RV as RecordView
    participant VM as NoteViewModel
    participant WS as WhisperService
    participant NM as NoteModel
    participant SD as SwiftData
    
    U->>NV: Tap "Record" button
    NV->>RV: Present RecordView
    
    U->>RV: Tap "Start Recording"
    RV->>RV: Initialize audio recorder
    RV->>RV: Start recording audio
    
    U->>RV: Tap "Stop Recording"
    RV->>RV: Stop recording
    RV->>RV: Save audio file
    RV->>WS: Send audio for transcription
    
    WS->>WS: Process audio with Whisper
    WS->>WS: Detect language
    WS->>RV: Return transcription text
    
    U->>RV: Tap "Save Note"
    RV->>VM: Create note with audio and transcription
    VM->>NM: Initialize NoteModel
    VM->>SD: Save note to database
    SD->>VM: Confirm save
    VM->>RV: Note saved successfully
    RV->>NV: Dismiss RecordView
    
    NV->>VM: Refresh notes list
    VM->>SD: Fetch all notes
    SD->>VM: Return notes data
    VM->>NV: Update UI with new note
```

## Text Note Creation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant NV as NoteListView
    participant NNV as NewNoteView
    participant VM as NoteViewModel
    participant NTG as NLTitleGenerator
    participant NM as NoteModel
    participant SD as SwiftData
    
    U->>NV: Tap "Add Note" button
    NV->>NNV: Present NewNoteView
    
    U->>NNV: Enter title and content
    U->>NNV: Tap "Save" button
    
    NNV->>VM: Create note with title and content
    VM->>NTG: Generate title if empty
    NTG->>VM: Return generated title
    VM->>NM: Initialize NoteModel
    VM->>SD: Save note to database
    SD->>VM: Confirm save
    VM->>NNV: Note saved successfully
    NNV->>NV: Dismiss NewNoteView
    
    NV->>VM: Refresh notes list
    VM->>SD: Fetch all notes
    SD->>VM: Return notes data
    VM->>NV: Update UI with notes
```

## Note Search Flow

```mermaid
sequenceDiagram
    participant U as User
    participant NV as NoteListView
    participant VM as NoteViewModel
    participant SD as SwiftData
    
    U->>NV: Enter search text
    NV->>VM: Search notes with query
    VM->>SD: Query notes by title/content
    SD->>VM: Return filtered notes
    VM->>NV: Update UI with search results
    
    U->>NV: Clear search text
    NV->>VM: Clear search
    VM->>SD: Fetch all notes
    SD->>VM: Return all notes
    VM->>NV: Update UI with all notes
```

## Note Deletion Flow

```mermaid
sequenceDiagram
    participant U as User
    participant DV as DetailView
    participant VM as NoteViewModel
    participant SD as SwiftData
    participant NV as NoteListView
    
    U->>DV: Tap "Delete" button
    DV->>DV: Show confirmation dialog
    U->>DV: Confirm deletion
    DV->>VM: Delete note
    VM->>SD: Remove note from database
    SD->>VM: Confirm deletion
    VM->>DV: Note deleted successfully
    DV->>NV: Navigate back to list
    
    NV->>VM: Refresh notes list
    VM->>SD: Fetch remaining notes
    SD->>VM: Return updated notes
    VM->>NV: Update UI without deleted note
```

## Audio Playback Flow

```mermaid
sequenceDiagram
    participant U as User
    participant DV as DetailView
    participant AP as AVAudioPlayer
    
    U->>DV: Tap "Play" button
    DV->>AP: Initialize audio player with note's audio URL
    AP->>DV: Audio player ready
    DV->>AP: Start playback
    AP->>DV: Audio playing
    
    U->>DV: Tap "Stop" button
    DV->>AP: Stop playback
    AP->>DV: Audio stopped
```

## Error Handling Flow

```mermaid
sequenceDiagram
    participant U as User
    participant RV as RecordView
    participant WS as WhisperService
    participant VM as NoteViewModel
    
    U->>RV: Record and save audio
    RV->>WS: Request transcription
    WS->>WS: Transcription fails
    
    WS->>RV: Return error message
    RV->>VM: Handle transcription error
    VM->>RV: Show error to user
    RV->>U: Display error notification
    
    U->>RV: Retry transcription
    RV->>WS: Retry transcription request
    WS->>RV: Successful transcription
    RV->>VM: Save note with transcription
```

## Key Interactions Explained

### 1. Audio Note Creation
- User initiates recording through RecordView
- Audio is captured and saved locally
- WhisperService processes audio for transcription
- Note is created with both audio and transcribed text
- SwiftData persists the note

### 2. Text Note Creation
- User creates note through NewNoteView
- NLTitleGenerator may generate title if not provided
- Note is saved to SwiftData
- UI is updated to reflect new note

### 3. Search Functionality
- Real-time search as user types
- SwiftData queries filter notes by title and content
- UI updates immediately with search results

### 4. Data Persistence
- All operations go through SwiftData
- Changes are immediately persisted
- UI reflects current data state

### 5. Error Handling
- Graceful handling of transcription failures
- User-friendly error messages
- Retry mechanisms for failed operations 