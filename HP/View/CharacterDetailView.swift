import SwiftUI

struct CharacterDetailView: View {
    var viewModel: CharacterDetailViewModel
    @State private var uiImage: UIImage?
    
    var body: some View {
        VStack {
            Text(viewModel.character.fullName ?? " NO FULL NAME TODAY ").font(.title).fontWeight(.bold)
            
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
            Text("House: \(viewModel.character.hogwartsHouse)").font(.title2).fontWeight(.semibold)
            Text("Birthdate: \(viewModel.character.birthdate)").font(.title3)
        }
    }
}
