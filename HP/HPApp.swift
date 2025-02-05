import SwiftUI
import SwiftData

@main
struct HPApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Book.self, Character.self)
        } catch {
            fatalError("Failed to create ModelContainer.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
                .modelContainer(container)
        }
    }
}
