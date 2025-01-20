import Foundation
import Observation

@Observable
class CharactersViewModel {
    var characters = [Character]()
    var searchText: String = ""
    private var hasReachedEnd = false
    var didFetchContent = false
    
    let max: Int = 5
    var page: Int = 1
    
    var filteredCharacters: [Character] {
        guard !searchText.isEmpty else { return characters }
        return characters.filter { character in
            character.fullName.lowercased().contains(searchText.lowercased())
        }
    }
    
    func fetchNextPage() async {
        page += 1
        let urlString = "https://potterapi-fedeperin.vercel.app/en/characters?max=\(max)&page=\(page)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodedData = (try? decoder.decode([Character].self, from: data)) ?? []
            
            characters.append(contentsOf: decodedData)
            print("fetching 5 more characters")
        } catch {
            print("An error occurred")
        }
    }
    
    func fetchCharacters() async {
        let urlString = "https://potterapi-fedeperin.vercel.app/en/characters?max=\(max)&page=\(page)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode([Character].self, from: data)
            
            DispatchQueue.main.async {
                self.characters.append(contentsOf: decodedData)
            }
            print("fetching")
            didFetchContent = true
        } catch {
            print("List is fully fetched")
        } 
    }
}
