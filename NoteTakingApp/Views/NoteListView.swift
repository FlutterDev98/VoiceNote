import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoteModel.createdAt, order: .reverse) private var notes: [NoteModel]
    @State private var showingNewNote = false
    @State private var selectedNote: NoteModel?
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    
    var filteredNotes: [NoteModel] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ZStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Search Bar
                            if isSearching {
                                HStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.purple)
                                            .font(.system(size: 18, weight: .medium))
                                        
                                        TextField("Search notes...", text: $searchText)
                                            .textFieldStyle(.plain)
                                            .focused($isSearchFocused)
                                            .font(.system(size: 16))
                                            .tint(.purple)
                                        
                                        if !searchText.isEmpty {
                                            Button(action: {
                                                searchText = ""
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.purple.opacity(0.6))
                                                    .font(.system(size: 18))
                                            }
                                            .transition(.opacity)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.purple.opacity(0.1), radius: 8, x: 0, y: 4)
                                    )
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isSearching = false
                                            searchText = ""
                                            isSearchFocused = false
                                        }
                                    }) {
                                        Text("Cancel")
                                            .foregroundColor(.purple)
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // Notes List as Cards
                            ForEach(filteredNotes) { note in
                                Button {
                                    selectedNote = note
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        if let audioPath = note.audioFilePath {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.purple.opacity(0.1))
                                                    .frame(width: 56, height: 56)
                                                Image(systemName: "mic.fill")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(.purple)
                                            }
                                        } else {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.gray.opacity(0.1))
                                                    .frame(width: 56, height: 56)
                                                Image(systemName: "doc.text")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(note.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(note.content)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                            Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(18)
                                    .shadow(color: Color.purple.opacity(0.08), radius: 6, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 80)
                    }
                    .background(Color.clear)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
            }
            .navigationTitle("VoiceNote")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isSearching = true
                            isSearchFocused = true
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    
                    Button {
                        showingNewNote = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
                                .frame(width: 32, height: 32)
                                .shadow(color: Color.purple.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewNote) {
                NewNoteView()
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
        }
    }
}

#Preview {
    NoteListView()
        .modelContainer(for: NoteModel.self, inMemory: true)
} 
