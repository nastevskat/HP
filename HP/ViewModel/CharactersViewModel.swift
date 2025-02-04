import Foundation
import Observation
import SwiftData

enum MyError: LocalizedError {
    case networkError(Error, String)
    case dataError(Error)
}

//class NetworkService {
//    func fetch() async throws -> Data {
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            return data
//        } catch {
//            throw MyError.networkError(error, "Network error happened")
//        }
//    }
//}

@Observable class CharactersViewModel {
    var characters = [Character]()
    var modelContext: ModelContext
    let max: Int = 5
    var page: Int = 1
    var showError = false
    var errorMessage: String?
    var isLoading = false
    
    let fileManagerHelper: FileManagerHelper
    
//    let networkService: NetworkService

    init(modelContext: ModelContext, fileManagerHelper: FileManagerHelper) {
        self.modelContext = modelContext
        self.fileManagerHelper = fileManagerHelper
//        self.networkService = NetworkService()
    }
    
    private func isCharacterInDatabase( _ CharacterId: Int) throws -> Bool {
        let descriptor = FetchDescriptor<Character>(predicate: #Predicate<Character> { character in
            character.id == CharacterId
        })
        return try modelContext.fetch(descriptor).first != nil
    }
    
    func fetchCharacters() async throws {
        do {
            let descriptor = FetchDescriptor<Character>(sortBy: [SortDescriptor(\.fullName)])
            let localCount = try modelContext.fetchCount(descriptor)
            
            if localCount == 0 {
                print("fetching characters from api")
                await fetchCharactersFromAPI()
            } else {
                print("fetching characters from local storage")
                fetchCharactersFromLocalStorage()
            }
        } catch {
            errorMessage = "Failed to fetch characters"
            isLoading = false
            showError = true
            throw error
        }
    }
    
    func fetchCharactersFromAPI(page: Int? = nil) async {
        isLoading = true

        let pageToFetch = page ?? self.page
        let urlString = "https://potterapi-fedeperin.vercel.app/en/characters?max=\(max)&page=\(pageToFetch)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid URL"
            showError = true
//            throw URLError(.badURL)
            return
        }
        
        print("page number \(pageToFetch)")
        
        do {
//            let datada = try await networkService.fetch()
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([Character].self, from: data)
            
            for var character in decodedData {
                if try !isCharacterInDatabase(character.id) {
                    modelContext.insert(character)
                    print("inserting character in db")
                    _ = await fileManagerHelper.loadImage(for: &character)
                }
            }
            fileManagerHelper.modelContextSave()
            fetchCharactersFromLocalStorage()
            
//        } catch let error as MyError {
//            switch error {
//            case .networkError(let netError, let string):
//                errorMessage = string
//            }
        }
//        catch let error as URLError {
//            switch error.code {
//            case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
//                isLoading = false
//                errorMessage = "Network connection error: \(error.localizedDescription)"
//            default:
//                isLoading = false
//                errorMessage = "Unexpected error: \(error.localizedDescription)"
//            }
//            isLoading = false
//            showError = true
//         throw error
//        }
        catch {
            isLoading = false
            errorMessage = "You've reached the end of the list. There's nothing left to fetch."
            showError = true
//            throw error
        }
        isLoading = false
    }
    
    func fetchCharactersFromLocalStorage() {
        do {
            let descriptor = FetchDescriptor<Character>(sortBy: [SortDescriptor(\.fullName)])
            characters = try modelContext.fetch(descriptor)
            print("loaded \(characters.count) characters from local storage")
            for character in characters {
                print("character id: \(character.id), localImgURL: \(character.localImgURL ?? "nil")")
            }
        } catch {
            isLoading = false
            print("local storage fetch failed: \(error.localizedDescription)")
        }
    }
    
    func fetchNextPage() async {
        page += 1
        print("fetching characters page: \(page)")
        await fetchCharactersFromAPI(page: page)
    }
    
    func refreshCharacters() async throws {
        page = 1

        do {
            let descriptor = FetchDescriptor<Character>()
            let existingCharacters = try modelContext.fetch(descriptor)
            for character in existingCharacters {
                modelContext.delete(character)
            }
            fileManagerHelper.modelContextSave()
        } catch {
            print("Error clearing database: \(error)")
        }
         await fetchCharactersFromAPI()
    }
}
