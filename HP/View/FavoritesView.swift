import SwiftUI

struct FavoritesView: View {
    var viewModel: BooksViewModel

    var favoriteBooks: [Book] {
        viewModel.books.filter { $0.isFavorite }
    }
    
    var body: some View {
        List {
            Section(header: Text("^[Found \(favoriteBooks.count) favorite book](inflect: true).")) {
                ForEach(favoriteBooks) { book in
                    NavigationLink {
                        BookDetailView(viewModel: viewModel, book: book)
                    } label: {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text(book.title)
                                .font(.largeTitle)
                                .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorite Books")
    }
}
