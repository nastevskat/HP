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
    let networkService: NetworkService

    
    init(modelContext: ModelContext, fileManagerHelper: FileManagerHelper, networkService: NetworkService) {
        self.modelContext = modelContext
        self.fileManagerHelper = fileManagerHelper
        self.networkService = networkService
    }
    
    private func isBookInDatabase(_ bookId: Int) throws -> Bool {
        let descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> { book in
            book.id == bookId
        })
        return try modelContext.fetch(descriptor).first != nil
    }
    
    func fetchBooks() async  {
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
            networkService.handleError(error)
        }
        isLoading = false
    }
    
    func fetchBooksFromAPI(page: Int? = nil) async throws {
        let pageToFetch = page ?? self.page
        let urlString = "https://potterapi-fedeperin.vercel.app/en/books?max=\(max)&page=\(pageToFetch)"
        
        guard let url = URL(string: urlString) else {
            throw AppError.invalidURL
        }
        
        print("page number \(pageToFetch)")
        
        do {
            let decodedData: [Book] = try await networkService.loadData(from: url)
            
            for var book in decodedData {
                if try !isBookInDatabase(book.id) {
                    modelContext.insert(book)
                    print("inserting book in db")
                    _ = await fileManagerHelper.loadImage(for: &book)
                }
            }
            fileManagerHelper.modelContextSave()
            fetchBooksFromLocalStorage()
        }
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
        guard !isLoading else { return }
        page += 1
              
        do {
          try await fetchBooksFromAPI(page: page)
        } catch {
          if let bookError = error as? AppError, bookError.errorMessage != "You've reached the end of the list" {
              networkService.handleError(error)
            }
        page -= 1
      }
    }
    
    func refreshBooks() async {
        isLoading = true
        page = 1
        
        do {
            let descriptor = FetchDescriptor<Book>()
            let existingBooks = try modelContext.fetch(descriptor)
            for book in existingBooks {
                modelContext.delete(book)
            }
            fileManagerHelper.modelContextSave()
            
            try await fetchBooksFromAPI()
            
        } catch {
            networkService.handleError(error)
        }
        isLoading = false
    }
}
