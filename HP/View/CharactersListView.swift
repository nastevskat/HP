import SwiftUI

struct CharactersListView: View {
    @Bindable var viewModel: CharactersViewModel
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("^[Found \(viewModel.filteredCharacters.count) character](inflect: true).")) {
                    ForEach(viewModel.filteredCharacters) { character in
                        NavigationLink {
                            CharacterDetailView(character: character)
                        } label: {
                            if idiom == .pad {
                                Text(character.fullName).font(.title)
                            } else {
                                Text(character.fullName).font(.title).padding()
                            }
                        }
                        .task {
                            await loadMoreContentIfNeeded(currentCharacter: character)
                        }
                    }
                }
            }
            .task {
                if !viewModel.didFetchContent {
                    await viewModel.fetchCharacters()
                }
            }
            .navigationTitle("Characters")
            .searchable(text: $viewModel.searchText)
        }
    }
    
    private func loadMoreContentIfNeeded(currentCharacter: Character) async {
        if currentCharacter.id == viewModel.filteredCharacters.last?.id {
            await viewModel.fetchNextPage()
        }
    }
}
