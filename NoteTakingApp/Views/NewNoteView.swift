import SwiftUI
import SwiftData

struct NewNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Title Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        TextField("Enter title", text: $title)
                            .font(.title3)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.purple.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            .focused($focusedField, equals: .title)
                    }
                    .padding(.horizontal)
                    
                    // Content Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        TextEditor(text: $content)
                            .font(.body)
                            .frame(minHeight: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.purple.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            .focused($focusedField, equals: .content)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .bold()
                    .foregroundColor(.purple)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                focusedField = .title
            }
        }
    }
    
    private func saveNote() {
        if title.isEmpty {
            alertMessage = "Please enter a title"
            showingAlert = true
            return
        }
        
        let newNote = NoteModel(title: title, content: content)
        modelContext.insert(newNote)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save note: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    NewNoteView()
        .modelContainer(for: NoteModel.self, inMemory: true)
} 
