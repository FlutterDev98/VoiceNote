import SwiftUI
import SwiftData

@main
struct NoteTakingApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: NoteModel.self)
    }
} 