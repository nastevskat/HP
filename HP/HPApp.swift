import SwiftUI
import SwiftData

@main
struct HPApp: App {
    let container: ModelContainer
    let networkService: NetworkService
    let fileManagerHelper: FileManagerHelper
    
    init() {
        do {
            container = try ModelContainer(for: Book.self, Character.self)
            
            networkService = NetworkService()
            
            fileManagerHelper = FileManagerHelper(modelContext: container.mainContext, networkService: networkService)
        } catch {
            fatalError("Failed to create ModelContainer or service.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext,
                        networkService: networkService,
                        fileManagerHelper: fileManagerHelper)
        }
    }
}
