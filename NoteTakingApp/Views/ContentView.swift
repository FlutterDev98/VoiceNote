import SwiftUI
import SwiftData

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabItems: [(icon: String, label: String)] = [
        ("list.bullet.rectangle", "Notes"),
        ("mic", "Record"),
        ("info.circle", "About")
    ]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabItems.count, id: \ .self) { idx in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = idx
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            if selectedTab == idx {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.purple.opacity(0.12))
                                    .frame(width: 44, height: 44)
                            }
                            Image(systemName: tabItems[idx].icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(selectedTab == idx ? .purple : .gray)
                        }
                        Text(tabItems[idx].label)
                            .font(.caption2)
                            .fontWeight(selectedTab == idx ? .semibold : .regular)
                            .foregroundColor(selectedTab == idx ? .purple : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.purple.opacity(0.18), radius: 16, x: 0, y: 6)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: NoteListView()
                case 1: RecordView(selectedTab: $selectedTab)
                case 2: AboutView()
                default: NoteListView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6).ignoresSafeArea())
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NoteModel.self, inMemory: true)
} 
