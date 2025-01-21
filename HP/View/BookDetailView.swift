import SwiftUI

struct BookDetailView: View {
    let viewModel: BooksViewModel
    var book: Book
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                Text(book.title)
                    .font(idiom == .pad ? .largeTitle : .title)
                    .fontWeight(.bold)
                
                AsyncImage(url: URL(string: book.cover)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 300, height: 400)
                
                Text(book.desc)
                    .font(.title3)
                    .padding()
                
                Text("Release date: \(book.releaseDate)")
                
                HStack {
                    Text("Add to Favorites:")
                    Button {
                        viewModel.toggleFavorite(for: book)
                    } label: {
                        Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(book.isFavorite ? .red : .gray)
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}
