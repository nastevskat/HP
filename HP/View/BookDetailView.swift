import SwiftUI

struct BookDetailView: View {
    let viewModel: BooksViewModel
    var book: Book
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @State private var uiImage: UIImage?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                Text(book.title)
                    .font(idiom == .pad ? .largeTitle : .title)
                    .fontWeight(.bold)
                
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 400)
                } else {
                    ProgressView()
                        .frame(width: 300, height: 400)
                        .task {
                            if let data = await viewModel.loadImage(for: book) {
                                uiImage = UIImage(data: data)
                            }
                        }
                }
                
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
