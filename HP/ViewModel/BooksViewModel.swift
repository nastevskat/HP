import Foundation
import Observation
import SwiftData

@Observable class BooksViewModel {
    var books = [Book]()
    var modelContext: ModelContext
    var count: Int = 0
    var didFetchContent = false
    let max: Int = 5
    var page: Int = 1
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchNextPage() async {
        page += 1
        let urlString = "https://potterapi-fedeperin.vercel.app/en/books?max=\(max)&page=\(page)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodedData = (try? decoder.decode([Book].self, from: data)) ?? []
            books.append(contentsOf: decodedData)
            
            for book in decodedData {
                self.modelContext.insert(book)
            }
            
            modelContextSave()
            print("fetching 5 more books")
        } catch {
            print("An error occurred")
        }
    }
    
    func fetchBooksFromAPI() async {
        page = 1
        do {
            let descriptor = FetchDescriptor<Book>()
            let existingBooks = try modelContext.fetch(descriptor)
            existingBooks.forEach { book in
                modelContext.delete(book)
            }
            
            modelContextSave()
            books.removeAll()
        } catch {
            print("Error clearing data: \(error.localizedDescription)")
        }
        
        let urlString = "https://potterapi-fedeperin.vercel.app/en/books?max=\(max)&page=\(page)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode([Book].self, from: data)
            
            DispatchQueue.main.async {
                self.books.append(contentsOf: decodedData)
                
                for book in decodedData {
                    self.modelContext.insert(book)
                }
                
                self.modelContextSave()
            }
        } catch let error as DecodingError {
            print(error.localizedDescription)
        } catch {
            print("An error occurred")
        }
    }
    
    func fetchBooks() async {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            count = try modelContext.fetchCount(descriptor)
        } catch {
            print("fetch failed")
        }
        
        print(count)
        
        if count == 0 {
            print("fetching from API")
            await fetchBooksFromAPI()
        } else {
            print("fetching from local storage")
            fetchBooksFromLocalStorage()
        }
        
        didFetchContent = true
    }
    
    func fetchBooksFromLocalStorage() {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            books = try modelContext.fetch(descriptor)
        } catch {
            print("fetch failed")
        }
    }
    
    func toggleFavorite(for bookId: Int) {
        let descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> { book in
            book.id == bookId
        })
        
        do {
            if let book = try modelContext.fetch(descriptor).first {
                book.isFavorite.toggle()
                
                if let index = books.firstIndex(where: { $0.id == bookId }) {
                    books[index].isFavorite = book.isFavorite
                }
                
                modelContextSave()
            }
        } catch {
            print("Error toggling favorite: \(error.localizedDescription)")
        }
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
