import SwiftUI

struct BooksListView: View {
    var viewModel: BooksViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section(header: Text("^[Found \(viewModel.books.count) book](inflect: true).")) {
                        ForEach(viewModel.books) { book in
                            NavigationLink {
                                BookDetailView(viewModel: BookDetailViewModel(book: book, fileManagerHelper: viewModel.fileManagerHelper))
                            } label: {
                                HStack {
                                    Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(book.isFavorite ? .red : .gray)
                                    
                                    Text(book.title ?? "no title sorry")
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
                .navigationTitle("Books")
                .task {
                    do {
                        try await viewModel.fetchBooks()
                    } catch {
                        print("Error fetching books: \(error)")
                    }
                }
                .refreshable {
                    do {
                        print("refreshing characters")
                        try await viewModel.refreshBooks()
                    } catch {
                        print("Error refreshing books: \(error)")
                    }
                }
                .alert("Error", isPresented: .constant(viewModel.showError)) {
                    Button("Dismiss") {
                        viewModel.showError = false
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "Something went wrong")
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2)
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
        }
    }
    
    private func loadMoreContentIfNeeded(currentBook: Book) async {
        if currentBook.id == viewModel.books.last?.id {
            await viewModel.fetchNextPage()
        }
    }
}
