import SwiftUI

struct BookDetailView: View {
    var viewModel: BookDetailViewModel
    @State private var uiImage: UIImage?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                Text(viewModel.book.title ?? "No title today")
                    .font(.title)
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
                            if let data = await viewModel.loadImageData() {
                                uiImage = UIImage(data: data)
                            }
                        }
                }
                
                Text(viewModel.book.desc)
                    .font(.title3)
                    .padding()
                
                Text("Release date: \(viewModel.book.releaseDate)")
                
                HStack {
                    Text("Add to Favorites:")
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.book.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.book.isFavorite ? .red : .gray)
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}
