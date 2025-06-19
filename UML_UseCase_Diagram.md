# Use Case Diagram - VoiceNote

```mermaid
graph TB
    subgraph "VoiceNote System"
        subgraph "Note Management"
            UC1[Create Note]
            UC2[View Note List]
            UC3[Edit Note]
            UC4[Delete Note]
            UC5[Search Notes]
        end
        
        subgraph "Audio Features"
            UC6[Record Audio]
            UC7[Play Audio]
            UC8[Transcribe Audio]
            UC9[Detect Language]
            UC10[Translate Content]
        end
        
        subgraph "Data Management"
            UC11[Save Note]
            UC12[Load Notes]
            UC13[Export Data]
        end
    end
    
    subgraph "External Systems"
        ES1[Whisper Server]
        ES2[CoreML Models]
        ES3[Device Storage]
    end
    
    subgraph "Actors"
        A1[User]
        A2[System]
    end
    
    %% User interactions
    A1 --> UC1
    A1 --> UC2
    A1 --> UC3
    A1 --> UC4
    A1 --> UC5
    A1 --> UC6
    A1 --> UC7
    
    %% System interactions
    A2 --> UC8
    A2 --> UC9
    A2 --> UC10
    A2 --> UC11
    A2 --> UC12
    A2 --> UC13
    
    %% External system interactions
    UC8 --> ES1
    UC10 --> ES2
    UC11 --> ES3
    UC12 --> ES3
    
    %% Include relationships
    UC1 -.->|include| UC11
    UC3 -.->|include| UC11
    UC6 -.->|include| UC8
    UC8 -.->|include| UC9
    UC9 -.->|include| UC10
    
    %% Extend relationships
    UC2 -.->|extend| UC5
    UC7 -.->|extend| UC6
    
    style A1 fill:#e1f5fe
    style A2 fill:#f3e5f5
    style ES1 fill:#fff3e0
    style ES2 fill:#fff3e0
    style ES3 fill:#fff3e0
```

## Use Case Descriptions

### Primary Actors
- **User:** The person using the VoiceNote to create and manage notes
- **System:** The application itself performing automated tasks

### External Systems
- **Whisper Server:** Local server providing audio transcription services
- **CoreML Models:** Apple's machine learning framework for translation
- **Device Storage:** Local storage for data persistence

### Main Use Cases

1. **Create Note (UC1)**
   - Actor: User
   - Description: User creates a new text note with title and content
   - Preconditions: App is launched and user is authenticated
   - Postconditions: New note is saved to local storage

2. **Record Audio (UC6)**
   - Actor: User
   - Description: User records audio using device microphone
   - Preconditions: Microphone permissions granted
   - Postconditions: Audio file is created and attached to note

3. **Transcribe Audio (UC8)**
   - Actor: System
   - Description: System automatically transcribes recorded audio to text
   - Preconditions: Audio file exists
   - Postconditions: Transcribed text is saved with the note

4. **Translate Content (UC10)**
   - Actor: System
   - Description: System translates non-English content to English
   - Preconditions: Non-English content is detected
   - Postconditions: Translated text is saved with the note

5. **Search Notes (UC5)**
   - Actor: User
   - Description: User searches through notes by title or content
   - Preconditions: Notes exist in the system
   - Postconditions: Matching notes are displayed 