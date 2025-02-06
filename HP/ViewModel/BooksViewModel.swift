import Foundation
import Observation
import SwiftData

//
//class AllBooks {
//    static let shared = AllBooks()
//    
//    var books: [Book] = []
//}

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
    
    func fetchBooks() async {
        isLoading = true
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
            handleError(error)
        }
        isLoading = false
    }
    
    func fetchBooksFromAPI(page: Int? = nil) async throws {
        let pageToFetch = page ?? self.page
    
        print("page number \(pageToFetch)")
        
        let decodedData: [Book] = try await networkService.loadData(for: APIEndpoint.book(max: max, pageToFetch: pageToFetch))
        
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
    
    func fetchBooksFromLocalStorage() {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            books = try modelContext.fetch(descriptor)
          //  AllBooks.shared.books = books // sign
            print("Loaded \(books.count) books from storage")
            for book in books {
                print("Book ID: \(book.id), localImgURL: \(book.localImgURL ?? "nil")")
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
            try await fetchBooksFromAPI(page: page)
        } catch {
            handleError(error)
        }
        isLoading = false
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
            handleError(error)
        }
        isLoading = false
    }
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            errorMessage = appError.errorMessage
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
        isLoading = false
    }
}
