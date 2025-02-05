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
                                if character.id == viewModel.characters.last?.id {
                                    await viewModel.fetchNextPage()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Characters")
                .task {
                    await viewModel.fetchCharacters()
                }
                .refreshable {
                    print("refreshing characters")
                    await viewModel.refreshCharacters()
                }
                .alert(isPresented: .constant(viewModel.showError)) {
                    Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "An unexpected error occurred. Please try again"), primaryButton: .default(Text("Retry")) {
                        Task {
                            await viewModel.fetchCharacters()
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
        }
    }
}
