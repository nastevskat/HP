import SwiftUI

struct CharacterDetailView: View {
    var character: Character
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var body: some View {
        VStack {
            if idiom == .pad {
                Text(character.fullName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            } else {
                Text(character.fullName).font(.title).fontWeight(.bold)
            }
            AsyncImage(url: URL(string: character.image)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 300, height: 400)
            Text("House: \(character.hogwartsHouse)").font(.title2).fontWeight(.semibold)
            Text("Birthdate: \(character.birthdate)").font(.title3)
        }
    }
}
