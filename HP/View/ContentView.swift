import SwiftUI
import SwiftData

struct ContentView: View {
    @State var bookVM: BooksViewModel
    @State var characterVM: CharactersViewModel
    
    init(modelContext: ModelContext, networkService: NetworkService, fileManagerHelper: FileManagerHelper) {
        
        let bookVM = BooksViewModel(
            modelContext: modelContext,
            fileManagerHelper: fileManagerHelper,
            networkService: networkService
        )
        _bookVM = State(initialValue: bookVM)
        
        let characterVM = CharactersViewModel(
            modelContext: modelContext,
            fileManagerHelper: fileManagerHelper,
            networkService: networkService
        )
        _characterVM = State(initialValue: characterVM)
    }
    
    var body: some View {
        TabView {
            Tab("Books", systemImage: "books.vertical") {
                BooksListView(viewModel: bookVM)
            }
            Tab("Characters", systemImage: "person") {
                CharactersListView(viewModel: characterVM)
            }
        }
    }
}
