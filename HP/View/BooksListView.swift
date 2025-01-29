import SwiftUI
import SwiftData

struct BooksListView: View {
    let viewModel: BooksViewModel
    @State private var uiImage: UIImage?
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("^[Found \(viewModel.books.count) book](inflect: true).")) {
                    ForEach(viewModel.books) { book in
                        NavigationLink {
                            BookDetailView(viewModel: viewModel, book: book)
                        } label: {
                            HStack {
                                Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(book.isFavorite ? .red : .gray)
                                
                                Text(book.title)
                                    .font(.largeTitle)
                                    .padding()
                            }
                        }
                        .task {
                            await loadMoreContentIfNeeded(currentBook: book)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoritesView(viewModel: viewModel)) {
                        Image(systemName: "heart.fill")
                            .imageScale(.large)
                            .padding()
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Books")
            .task {
                await viewModel.fetchBooks()
            }
            .refreshable {
                print("refetching from API")
                viewModel.clearAllImages()
                await viewModel.fetchBooksFromAPI()
                }
        }
    }
    
    private func loadMoreContentIfNeeded(currentBook: Book) async {
        if currentBook.id == viewModel.books.last?.id {
            await viewModel.fetchNextPage()
        }
    }
}
