# Data Flow Diagrams (DFD) - VoiceNote

## Level 0 DFD (Context Diagram)

```mermaid
graph TB
    subgraph "VoiceNote System"
        APP[VoiceNote]
    end
    
    subgraph "External Entities"
        USER[User]
        DEVICE[Device Storage]
        WHISPER[Whisper Server]
        COREML[CoreML Models]
    end
    
    subgraph "Data Stores"
        NOTES[(Notes Database)]
        AUDIO[(Audio Files)]
    end
    
    %% User interactions
    USER -->|Create/Edit/Delete Notes| APP
    USER -->|Search Notes| APP
    USER -->|Record Audio| APP
    USER -->|Play Audio| APP
    APP -->|Display Notes| USER
    APP -->|Show Search Results| USER
    APP -->|Play Audio| USER
    
    %% Data storage
    APP -->|Save Notes| NOTES
    APP -->|Save Audio| AUDIO
    NOTES -->|Load Notes| APP
    AUDIO -->|Load Audio| APP
    
    %% External processing
    APP -->|Send Audio| WHISPER
    WHISPER -->|Return Transcription| APP
    APP -->|Send Text| COREML
    COREML -->|Return Translation| APP
    
    %% Device storage
    DEVICE -->|Provide Storage| APP
    APP -->|Store Data| DEVICE
    
    style APP fill:#e3f2fd
    style USER fill:#f3e5f5
    style DEVICE fill:#fff3e0
    style WHISPER fill:#fff3e0
    style COREML fill:#fff3e0
    style NOTES fill:#e8f5e8
    style AUDIO fill:#e8f5e8
```

## Level 1 DFD (Main Processes)

```mermaid
graph TB
    subgraph "VoiceNote System"
        subgraph "User Interface Layer"
            P1[1.0<br/>Note Management UI]
            P2[2.0<br/>Audio Recording UI]
            P3[3.0<br/>Search Interface]
        end
        
        subgraph "Business Logic Layer"
            P4[4.0<br/>Note CRUD Operations]
            P5[5.0<br/>Audio Processing]
            P6[6.0<br/>Transcription Service]
            P7[7.0<br/>Translation Service]
            P8[8.0<br/>Search Engine]
        end
        
        subgraph "Data Layer"
            P9[9.0<br/>Data Persistence]
            P10[10.0<br/>Audio Storage]
        end
    end
    
    subgraph "External Systems"
        WHISPER[Whisper Server]
        COREML[CoreML Models]
    end
    
    subgraph "Data Stores"
        D1[(Notes Database)]
        D2[(Audio Files)]
        D3[(User Preferences)]
    end
    
    subgraph "External Entities"
        USER[User]
    end
    
    %% User interactions
    USER -->|Create/Edit/Delete Requests| P1
    USER -->|Audio Recording Commands| P2
    USER -->|Search Queries| P3
    P1 -->|Display Notes| USER
    P2 -->|Audio Feedback| USER
    P3 -->|Search Results| USER
    
    %% Process interactions
    P1 -->|Note Operations| P4
    P2 -->|Audio Data| P5
    P3 -->|Search Requests| P8
    
    P4 -->|CRUD Commands| P9
    P5 -->|Audio Files| P10
    P6 -->|Transcription Requests| WHISPER
    P7 -->|Translation Requests| COREML
    
    %% Data flows
    P9 -->|Save/Load Notes| D1
    P10 -->|Save/Load Audio| D2
    P6 -->|Transcribed Text| P4
    P7 -->|Translated Text| P4
    P8 -->|Query Notes| D1
    
    %% External responses
    WHISPER -->|Transcription Results| P6
    COREML -->|Translation Results| P7
    
    style P1 fill:#e3f2fd
    style P2 fill:#e3f2fd
    style P3 fill:#e3f2fd
    style P4 fill:#f3e5f5
    style P5 fill:#f3e5f5
    style P6 fill:#f3e5f5
    style P7 fill:#f3e5f5
    style P8 fill:#f3e5f5
    style P9 fill:#fff3e0
    style P10 fill:#fff3e0
    style D1 fill:#e8f5e8
    style D2 fill:#e8f5e8
    style D3 fill:#e8f5e8
```

## Level 2 DFD (Detailed Processes)

### Note Creation Process

```mermaid
graph TB
    subgraph "Note Creation Process"
        P1_1[1.1<br/>Validate Input]
        P1_2[1.2<br/>Generate Title]
        P1_3[1.3<br/>Create Note Model]
        P1_4[1.4<br/>Save to Database]
        P1_5[1.5<br/>Update UI]
    end
    
    subgraph "Data Stores"
        D1[(Notes Database)]
        D3[(User Preferences)]
    end
    
    subgraph "External Services"
        NTG[NLTitleGenerator]
    end
    
    INPUT[User Input] --> P1_1
    P1_1 -->|Valid Data| P1_2
    P1_1 -->|Invalid Data| ERROR[Error Message]
    
    P1_2 -->|Title Required| NTG
    NTG -->|Generated Title| P1_2
    P1_2 -->|Complete Data| P1_3
    
    P1_3 -->|Note Model| P1_4
    P1_4 -->|Save Command| D1
    D1 -->|Confirmation| P1_4
    
    P1_4 -->|Success| P1_5
    P1_5 -->|Updated List| OUTPUT[Note List]
    
    style P1_1 fill:#e3f2fd
    style P1_2 fill:#e3f2fd
    style P1_3 fill:#e3f2fd
    style P1_4 fill:#e3f2fd
    style P1_5 fill:#e3f2fd
```

### Audio Recording and Transcription Process

```mermaid
graph TB
    subgraph "Audio Processing"
        P2_1[2.1<br/>Initialize Recorder]
        P2_2[2.2<br/>Record Audio]
        P2_3[2.3<br/>Save Audio File]
        P2_4[2.4<br/>Send to Whisper]
        P2_5[2.5<br/>Process Response]
        P2_6[2.6<br/>Detect Language]
        P2_7[2.7<br/>Translate if Needed]
    end
    
    subgraph "External Systems"
        WHISPER[Whisper Server]
        COREML[CoreML Models]
    end
    
    subgraph "Data Stores"
        D2[(Audio Files)]
        D1[(Notes Database)]
    end
    
    USER[User Command] --> P2_1
    P2_1 -->|Recorder Ready| P2_2
    P2_2 -->|Audio Data| P2_3
    P2_3 -->|Audio File| D2
    
    P2_3 -->|Audio URL| P2_4
    P2_4 -->|Audio Data| WHISPER
    WHISPER -->|Transcription| P2_5
    
    P2_5 -->|Text Content| P2_6
    P2_6 -->|Language Detected| P2_7
    P2_7 -->|Non-English| COREML
    COREML -->|Translation| P2_7
    
    P2_7 -->|Final Content| D1
    
    style P2_1 fill:#e3f2fd
    style P2_2 fill:#e3f2fd
    style P2_3 fill:#e3f2fd
    style P2_4 fill:#e3f2fd
    style P2_5 fill:#e3f2fd
    style P2_6 fill:#e3f2fd
    style P2_7 fill:#e3f2fd
```

### Search Process

```mermaid
graph TB
    subgraph "Search Process"
        P3_1[3.1<br/>Parse Query]
        P3_2[3.2<br/>Search Database]
        P3_3[3.3<br/>Filter Results]
        P3_4[3.4<br/>Sort Results]
        P3_5[3.5<br/>Format Output]
    end
    
    subgraph "Data Stores"
        D1[(Notes Database)]
    end
    
    QUERY[Search Query] --> P3_1
    P3_1 -->|Parsed Query| P3_2
    P3_2 -->|Database Query| D1
    D1 -->|Raw Results| P3_2
    
    P3_2 -->|All Notes| P3_3
    P3_3 -->|Filtered Notes| P3_4
    P3_4 -->|Sorted Notes| P3_5
    P3_5 -->|Formatted Results| RESULTS[Search Results]
    
    style P3_1 fill:#e3f2fd
    style P3_2 fill:#e3f2fd
    style P3_3 fill:#e3f2fd
    style P3_4 fill:#e3f2fd
    style P3_5 fill:#e3f2fd
```

## Data Dictionary

### Data Stores
- **Notes Database:** SwiftData persistent store containing NoteModel entities
- **Audio Files:** Local file system storage for recorded audio files
- **User Preferences:** App settings and user preferences

### Data Flows
- **User Input:** Text, audio commands, and search queries from user
- **Note Data:** Complete note information including title, content, audio, transcription, and translation
- **Audio Data:** Raw audio recordings and processed audio files
- **Transcription Data:** Text generated from audio recordings
- **Translation Data:** English translations of non-English content
- **Search Results:** Filtered and sorted note lists based on search criteria

### External Entities
- **User:** The person using the VoiceNote
- **Whisper Server:** Local server providing audio transcription services
- **CoreML Models:** Apple's machine learning framework for translation
- **Device Storage:** Local storage system for data persistence

### Key Processes
1. **Note Management:** CRUD operations for text and audio notes
2. **Audio Processing:** Recording, storage, and transcription of audio
3. **Language Processing:** Detection and translation of non-English content
4. **Search Operations:** Real-time search and filtering of notes
5. **Data Persistence:** Local storage and retrieval of all app data 