import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var bookVM: BooksViewModel
    @State var characterVM: CharactersViewModel
    
    let fileManagerHelper: FileManagerHelper
    
    init(modelContext: ModelContext) {
        let fileManagerHelper = FileManagerHelper(modelContext: modelContext)
        self.fileManagerHelper = fileManagerHelper
        
        let bookVM = BooksViewModel(modelContext: modelContext, fileManagerHelper: fileManagerHelper)
        _bookVM = State(initialValue: bookVM)
        
        let characterVM = CharactersViewModel(modelContext: modelContext, fileManagerHelper: fileManagerHelper)
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
