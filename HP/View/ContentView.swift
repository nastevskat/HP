import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var bookVM: BooksViewModel
    @State var characterVM: CharactersViewModel = CharactersViewModel()
    
    init(modelContext: ModelContext){
        let bookVM = BooksViewModel(modelContext: modelContext)
        _bookVM = State(initialValue: bookVM)
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
