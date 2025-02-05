import Foundation
import Observation
import SwiftData

@Observable class CharactersViewModel {
    var characters = [Character]()
    var modelContext: ModelContext
    let max: Int = 5
    var page: Int = 1
    var showError = false
    var errorMessage: String?
    var isLoading = false
    
    let fileManagerHelper: FileManagerHelper
    let networkService: NetworkService
    
    init(modelContext: ModelContext, fileManagerHelper: FileManagerHelper, networkService: NetworkService) {
        self.modelContext = modelContext
        self.fileManagerHelper = fileManagerHelper
        self.networkService = networkService
    }
    
    private func isCharacterInDatabase( _ CharacterId: Int) throws -> Bool {
        let descriptor = FetchDescriptor<Character>(predicate: #Predicate<Character> { character in
            character.id == CharacterId
        })
        return try modelContext.fetch(descriptor).first != nil
    }
    
    func fetchCharacters() async {
        isLoading = true
        do {
            let descriptor = FetchDescriptor<Character>(sortBy: [SortDescriptor(\.fullName)])
            let localCount = try modelContext.fetchCount(descriptor)
            
            if localCount == 0 {
                print("fetching characters from api")
                try await fetchCharactersFromAPI()
            } else {
                print("fetching characters from local storage")
                fetchCharactersFromLocalStorage()
            }
        } catch {
            handleError(error)
        }
        isLoading = false
    }
    
    func fetchCharactersFromAPI(page: Int? = nil) async throws {
        let pageToFetch = page ?? self.page
        let urlString = "https://potterapi-fedeperin.vercel.app/en/characters?max=\(max)&page=\(pageToFetch)"
        
        guard let url = URL(string: urlString) else {
            throw AppError.invalidURL
        }
        
        print("page number \(pageToFetch)")
        
        do {
            let decodedData: [Character] = try await networkService.loadData(from: url)
            
            for var character in decodedData {
                if try !isCharacterInDatabase(character.id) {
                    modelContext.insert(character)
                    print("inserting character in db")
                    _ = await fileManagerHelper.loadImage(for: &character)
                }
            }
            fileManagerHelper.modelContextSave()
            fetchCharactersFromLocalStorage()
        } catch {
            handleError(error)
        }
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
            handleError(error)
        }
    }
    
    func fetchNextPage() async {
        isLoading = true
        page += 1
        
        do {
            try await fetchCharactersFromAPI(page: page)
        } catch {
            handleError(error)
        }
        isLoading = false
    }
    
    func refreshCharacters() async {
        isLoading = true
        page = 1
        
        do {
            let descriptor = FetchDescriptor<Character>()
            let existingCharacters = try modelContext.fetch(descriptor)
            for character in existingCharacters {
                modelContext.delete(character)
            }
            fileManagerHelper.modelContextSave()
            try await fetchCharactersFromAPI()
        } catch {
            handleError(error)
        }
        isLoading = false
    }
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            errorMessage = appError.printErrorMessage()
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
        isLoading = false
    }
}
