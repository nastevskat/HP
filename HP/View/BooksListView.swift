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
                                if book.id == viewModel.books.last?.id {
                                    await viewModel.fetchNextPage()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Books")
                .task {
                    await viewModel.fetchBooks()
                }
                .refreshable {
                    print("refreshing characters")
                    await viewModel.refreshBooks()
                }
                .alert(isPresented: .constant(viewModel.showError)) {
                    Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "An unexpected error occurred. Please try again"), primaryButton: .default(Text("Retry")) {
                        Task {
                            await viewModel.fetchBooks()
                        }
                    }, secondaryButton: .cancel {
                        viewModel.showError = false
                    })
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
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
}
