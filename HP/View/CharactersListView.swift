import SwiftUI

struct CharactersListView: View {
    let viewModel: CharactersViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section(header: Text("^[Found \(viewModel.characters.count) character](inflect: true).")) {
                        ForEach(viewModel.characters) { character in
                            NavigationLink {
                                CharacterDetailView(viewModel: CharacterDetailViewModel(character: character, fileManagerHelper: viewModel.fileManagerHelper))
                            } label: {
                                Text(character.fullName ?? "no name").font(.title).padding()
                            }
                            .task {
                                await loadMoreContentIfNeeded(currentCharacter: character)
                            }
                        }
                    }
                }
                .navigationTitle("Characters")
                .task {
                    do {
                        try await viewModel.fetchCharacters()
                    } catch {
                        print("Error fetching books: \(error)")
                    }
                }
                .refreshable {
                    do {
                        print("refreshing characters")
                        try await viewModel.refreshCharacters()
                    } catch {
                        print("Error refreshing characters: \(error)")
                    }
                }
                .alert("Error", isPresented: .constant(viewModel.showError)) {
                    Button("Dismiss") {
                        viewModel.showError = false
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "something went wrong")
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
        }
    }
    
    private func loadMoreContentIfNeeded(currentCharacter: Character) async {
        if currentCharacter.id == viewModel.characters.last?.id {
            await viewModel.fetchNextPage()
        }
    }
}
