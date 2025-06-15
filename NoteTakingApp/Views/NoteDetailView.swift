import SwiftUI
import SwiftData
import AVFoundation

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioProgress: Double = 0
    @State private var audioTimer: Timer?
    
    let note: NoteModel?
    
    init(note: NoteModel? = nil) {
        self.note = note
        if let note = note {
            _title = State(initialValue: note.title)
            _content = State(initialValue: note.content)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.purple)
                        TextField("Enter title", text: $title)
                            .font(.title2)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.purple.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    }
                    
                    // Content Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.purple)
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.purple.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    }
                    
                    // Audio Player (if exists)
                    if let note = note, let audioPath = note.audioFilePath {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Voice Note")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            HStack {
                                Button(action: togglePlayback) {
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(
                                                gradient: Gradient(colors: [Color.purple, Color.pink]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing))
                                            .frame(width: 44, height: 44)
                                            .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                                        
                                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Slider(value: $audioProgress, in: 0...1) { editing in
                                        if !editing {
                                            seekAudio(to: audioProgress)
                                        }
                                    }
                                    .tint(.purple)
                                    
                                    Text(formatTime(audioPlayer?.currentTime ?? 0))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.purple.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Note Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.purple)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.purple.opacity(0.12))
                                    .shadow(color: Color.purple.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAlert = true
                        alertMessage = "Are you sure you want to delete this note?"
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.12))
                                    .shadow(color: Color.red.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                    }
                }
            }
            .alert("Confirmation", isPresented: $showingAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let note = note {
                        modelContext.delete(note)
                        try? modelContext.save()
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if let note = note, let audioPath = note.audioFilePath {
                    setupAudioPlayer(with: audioPath)
                }
            }
            .onDisappear {
                stopAudio()
            }
        }
    }
    
    private func saveNote() {
        if title.isEmpty {
            alertMessage = "Please enter a title"
            showingAlert = true
            return
        }
        
        if let existingNote = note {
            existingNote.title = title
            existingNote.content = content
        } else {
            let newNote = NoteModel(title: title, content: content)
            modelContext.insert(newNote)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save note: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func setupAudioPlayer(with audioPath: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(audioPath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
            startAudioTimer()
        } catch {
            alertMessage = "Failed to load audio: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        audioTimer?.invalidate()
        audioTimer = nil
    }
    
    private func seekAudio(to progress: Double) {
        guard let player = audioPlayer else { return }
        let time = progress * player.duration
        player.currentTime = time
    }
    
    private func startAudioTimer() {
        audioTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = audioPlayer else { return }
            audioProgress = player.currentTime / player.duration
            if !player.isPlaying {
                isPlaying = false
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NoteDetailView()
        .modelContainer(for: NoteModel.self, inMemory: true)
} 
