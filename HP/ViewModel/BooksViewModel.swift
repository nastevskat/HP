import Foundation
import Observation
import SwiftData

@Observable class BooksViewModel {
    var books = [Book]()
    let modelContext: ModelContext
    let max: Int = 5
    var page: Int = 1
    var showError = false
    var errorMessage: String?
    var isLoading = false
    
    let fileManagerHelper: FileManagerHelper
    
    init(modelContext: ModelContext, fileManagerHelper: FileManagerHelper) {
        self.modelContext = modelContext
        self.fileManagerHelper = fileManagerHelper
    }
    
    private func isBookInDatabase(_ bookId: Int) throws -> Bool {
        let descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> { book in
            book.id == bookId
        })
        return try modelContext.fetch(descriptor).first != nil
    }
    
    func fetchBooks() async throws {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            let localCount = try modelContext.fetchCount(descriptor)
            
            if localCount == 0 {
                print("fetching from API")
                try await fetchBooksFromAPI()
            } else {
                print("fetching from local storage")
                fetchBooksFromLocalStorage()
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch books"
            showError = true
            throw error
        }
    }
    
    func fetchBooksFromAPI(page: Int? = nil) async throws {
        isLoading = true
        
        let pageToFetch = page ?? self.page
        let urlString = "https://potterapi-fedeperin.vercel.app/en/books?max=\(max)&page=\(pageToFetch)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid URL"
            showError = true
            throw URLError(.badURL)
        }
        
        print("page number \(pageToFetch)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([Book].self, from: data)
            
            for var book in decodedData {
                if try !isBookInDatabase(book.id) {
                    modelContext.insert(book)
                    print("inserting book in db")
                    _ = await fileManagerHelper.loadImage(for: &book)
                }
            }
            
            fileManagerHelper.modelContextSave()
            fetchBooksFromLocalStorage()
            
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                errorMessage = "Network connection error: \(error.localizedDescription)"
            default:
                errorMessage = "Unexpected error: \(error.localizedDescription)"
            }
            isLoading = false
            showError = true
            throw error
        } catch {
            isLoading = false
            errorMessage = "You've reached the end of the list. There's nothing left to fetch."
            showError = true
            throw error
        }
        isLoading = false
    }
    
    func fetchBooksFromLocalStorage() {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            books = try modelContext.fetch(descriptor)
            print("Loaded \(books.count) books from storage")
            for book in books {
                print("Book ID: \(book.id), localImgURL: \(book.localImgURL ?? "nil")")
            }
        } catch {
            isLoading = false
            print("Local storage fetch failed: \(error.localizedDescription)")
        }
    }
    
    func fetchNextPage() async {
        page += 1
        print("fetching page: \(page)")
        try? await fetchBooksFromAPI(page: page)
    }
    
    func refreshBooks() async throws {
        page = 1
        
        do {
            let descriptor = FetchDescriptor<Book>()
            let existingBooks = try modelContext.fetch(descriptor)
            for book in existingBooks {
                modelContext.delete(book)
            }
            fileManagerHelper.modelContextSave()
        } catch {
            print("Error clearing database: \(error)")
        }
        
        try await fetchBooksFromAPI()
    }
    
}
