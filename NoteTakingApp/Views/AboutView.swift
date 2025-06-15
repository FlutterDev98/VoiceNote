import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        Text("VoiceNote")
                            .font(.title)
                            .bold()
                        Text("Version 1.0")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.purple.opacity(0.08), radius: 6, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        Text("Welcome to VoiceNote - Your Digital Notebook")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.primary)
                        
                        Text("Our app is designed to make note-taking simple, intuitive, and enjoyable. Whether you're a student, professional, or creative mind, we provide the perfect platform to capture your thoughts and ideas.")
                            .foregroundColor(.gray)
                        
                        Text("Key Features:")
                            .font(.headline)
                            .foregroundColor(.purple)
                            .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "pencil", title: "Quick Note Creation", description: "Create and edit notes instantly with our clean, distraction-free interface")
                            FeatureRow(icon: "folder", title: "Organized Storage", description: "Keep your notes neatly organized in customizable folders")
                            FeatureRow(icon: "lock.shield", title: "Secure Storage", description: "Your notes are safely stored and protected on your device")
                            FeatureRow(icon: "mic.fill", title: "Audio Recording", description: "Record and attach audio notes to capture your thoughts on the go")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.purple.opacity(0.08), radius: 6, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("About")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
} 
