import Foundation
import Observation
import SwiftData

@Observable class BooksViewModel {
    var books = [Book]()
    var modelContext: ModelContext
    let max: Int = 5
    var page: Int = 1
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchNextPage() async {
     
        print("fetching page: \(page)")
        await fetchBooksFromAPI(page: page + 1)
        
    }
    
    private func isBookInDatabase(_ bookId: Int) throws -> Bool {
        let descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> { book in
            book.id == bookId
        })
        return try modelContext.fetch(descriptor).first != nil
    }
    
    func fetchBooksFromAPI(page: Int = 1) async {
        let urlString = "https://potterapi-fedeperin.vercel.app/en/books?max=\(max)&page=\(page)"
        guard let url = URL(string: urlString) else {
            print("url string failed, fetching from db")
            fetchBooksFromLocalStorage()
            return
        }
        
        print("page number \(page)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([Book].self, from: data)
            
            if page == 1 {
                let descriptor = FetchDescriptor<Book>()
                let existingBooks = try modelContext.fetch(descriptor)
                for book in existingBooks {
                    modelContext.delete(book)
                    print("deleting everything")
                }
                modelContextSave()
            }
            
            for book in decodedData {
                if try !isBookInDatabase(book.id) {
                    modelContext.insert(book)
                    print("inserting book in db")
                }
            }
        
            modelContextSave()
            
        } catch let error as DecodingError {
            print("Decoding error: \(error.localizedDescription)")
        } catch {
            print("API or database error: \(error.localizedDescription)")
        }
        
        fetchBooksFromLocalStorage()
    }
    
    func fetchBooks() async {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            let localCount = try modelContext.fetchCount(descriptor)
            
            if localCount == 0 {
                print("fetching from API")
                await fetchBooksFromAPI(page: 1)
            } else {
                print("fetching from local storage")
                fetchBooksFromLocalStorage()
            }
            
        } catch {
            print("Initial fetch failed: \(error.localizedDescription)")
            fetchBooksFromLocalStorage()
        }
    }
    
    func fetchBooksFromLocalStorage() {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            books = try modelContext.fetch(descriptor)
            print("Loaded \(books.count) books from storage")
        } catch {
            print("Local storage fetch failed: \(error.localizedDescription)")
        }
    }
    
    func toggleFavorite(for book: Book) {
        book.isFavorite.toggle()
        modelContextSave()
    }
    
    func modelContextSave() {
        if self.modelContext.hasChanges {
            do {
                try modelContext.save()
            } catch {
                print("error saving to model context")
            }
        }
    }
}
