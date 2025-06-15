import SwiftUI
import AVFoundation
import SwiftData
import Pulsator
import NaturalLanguage

class PulsatorContainerView: UIView {
    let pulsator = Pulsator()
    var didSetup = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        pulsator.numPulse = 3
        pulsator.radius = 100
        pulsator.backgroundColor = UIColor.systemPurple.cgColor
        pulsator.animationDuration = 1.5
        pulsator.pulseInterval = 0.5
        layer.addSublayer(pulsator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pulsator.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

struct PulsatorView: UIViewRepresentable {
    let isRecording: Bool
    
    func makeUIView(context: Context) -> PulsatorContainerView {
        let view = PulsatorContainerView()
        return view
    }
    
    func updateUIView(_ uiView: PulsatorContainerView, context: Context) {
        if isRecording {
            uiView.pulsator.start()
        } else {
            uiView.pulsator.stop()
        }
    }
}

struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    @StateObject private var whisperService = WhisperService()
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var audioURL: URL?
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var recordingScale: CGFloat = 1.0
    @State private var progressTimer: Timer?
    @State private var simulatedProgress: Double = 0.0
    
    private let titleGenerator: TitleGenerating = NLTitleGenerator()
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack(spacing: 30) {
                if whisperService.isTranscribing {
                    ZStack {
                        Circle()
                            .stroke(Color.purple.opacity(0.2), lineWidth: 8)
                            .frame(width: 150, height: 150)
                        Circle()
                            .trim(from: 0, to: simulatedProgress)
                            .stroke(Color.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: simulatedProgress)
                        VStack {
                            Text("\(Int(simulatedProgress * 100))%")
                                .font(.title)
                                .bold()
                            Text("Transcribing")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text("Processing your voice note...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 25) {
                        ZStack {
                            if !isRecording {
                                Circle()
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 8)
                                    .frame(width: 150, height: 150)
                            }
                            if isRecording {
                                PulsatorView(isRecording: isRecording)
                                    .frame(width: 200, height: 200, alignment: .center)
                                    .background(Color.clear)
                            }
                            Button(action: {
                                if isRecording {
                                    stopRecording()
                                } else {
                                    startRecording()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.purple, Color.pink]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing))
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 8)
                                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        VStack(spacing: 10) {
                            Text(isRecording ? "Recording..." : "Tap to Record")
                                .font(.title3)
                                .foregroundColor(.primary)
                            if isRecording {
                                Text(formatDuration(recordingDuration))
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
            .padding()
            .animation(.easeInOut, value: isRecording)
            .animation(.easeInOut, value: whisperService.isTranscribing)
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onChange(of: whisperService.isTranscribing) { isTranscribing in
            if isTranscribing {
                startProgressSimulation()
            } else {
                stopProgressSimulation()
                simulatedProgress = 1.0
            }
        }
    }
    
    private func startProgressSimulation() {
        simulatedProgress = 0.0
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if simulatedProgress < 0.95 {
                simulatedProgress += 0.01
            }
        }
    }
    
    private func stopProgressSimulation() {
        progressTimer?.invalidate()
        progressTimer = nil
        simulatedProgress = 1.0
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let uniqueFileName = "audio_\(Date().timeIntervalSince1970).m4a"
            let audioFilename = documentsPath.appendingPathComponent(uniqueFileName)
            audioURL = audioFilename
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0
            recordingScale = 1.0
            
            // Start timer for recording duration
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                recordingDuration = audioRecorder?.currentTime ?? 0
            }
            
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        isRecording = false
        
        guard let audioURL = audioURL else {
            errorMessage = "No recording found"
            showingError = true
            return
        }
        let audioFilePath = audioURL.lastPathComponent
        
        Task {
            do {
                let transcribedText = try await whisperService.transcribeAudio(fileURL: audioURL)
                let generatedTitle = titleGenerator.generateTitle(from: transcribedText)
                let note = NoteModel(
                    title: generatedTitle,
                    content: transcribedText,
                    audioFilePath: audioFilePath
                )
                modelContext.insert(note)
                try modelContext.save()
                // Switch to Home tab (index 0) after saving
                selectedTab = 0
            } catch {
                errorMessage = "Transcription failed: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}

#Preview {
    RecordView(selectedTab: .constant(0))
        .modelContainer(for: NoteModel.self, inMemory: true)
} 
