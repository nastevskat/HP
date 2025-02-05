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
                .alert("Error", isPresented: .constant(viewModel.showError), presenting: viewModel.errorMessage) { _ in
                    VStack {
                        Button("Retry") {
                            Task {
                                await viewModel.fetchCharacters()
                            }
                        }
                        Button("Dismiss", role: .cancel) {
                            viewModel.showError = false
                        }
                    }
                } message: {
                    message in
                        Text(message)
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
