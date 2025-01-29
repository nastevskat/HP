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
    
    private func isBookInDatabase(_ bookId: Int) throws -> Bool {
        let descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> { book in
            book.id == bookId
        })
        return try modelContext.fetch(descriptor).first != nil
    }
    
    func fetchBooks() async {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            let localCount = try modelContext.fetchCount(descriptor)
            
            if localCount == 0 {
                print("fetching from API")
                await fetchBooksFromAPI()
            } else {
                print("fetching from local storage")
                fetchBooksFromLocalStorage()
            }
        } catch {
            print("Initial fetch failed: \(error.localizedDescription)")
            fetchBooksFromLocalStorage()
        }
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
                    //tuka dodadeno
                    _ = await loadImage(for: book)
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
    
    func fetchBooksFromLocalStorage() {
        do {
            let descriptor = FetchDescriptor<Book>(sortBy: [SortDescriptor(\.title)])
            books = try modelContext.fetch(descriptor)
            print("Loaded \(books.count) books from storage")
            for book in books {
                print("Book ID: \(book.id), localImgURL: \(book.localImgURL ?? "nil")")
            }
        } catch {
            print("Local storage fetch failed: \(error.localizedDescription)")
        }
    }
    
    func fetchNextPage() async {
        print("fetching page: \(page)")
        await fetchBooksFromAPI(page: page + 1)
        
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
    
    private func preloadImagesForExistingBooks() async {
        for book in books {
            if book.localImgURL == nil {
                _ = await loadImage(for: book)
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getRelativePath(from fullPath: String) -> String? {
        let documentsPath = getDocumentsDirectory().path
        return fullPath.replacingOccurrences(of: documentsPath, with: "")
    }
    
    private func getFullPath(from relativePath: String) -> String {
        return getDocumentsDirectory().path + relativePath
    }
    
    func loadImage(for book: Book) async -> Data? {
        print("Starting loadImage for book ID: \(book.id)")
        
        // Check cached image
        if let relativePath = book.localImgURL {
            let fullPath = getFullPath(from: relativePath)
            print("Checking full path: \(fullPath)")
            
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
                    print("Successfully read \(data.count) bytes from cache")
                    if !data.isEmpty {
                        return data
                    }
                } catch {
                    print("Error reading cached file: \(error)")
                }
            }
        }
        
        // Download new image
        guard let url = URL(string: book.cover) else {
            print("Invalid cover URL")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("Downloaded \(data.count) bytes")
            
            // Create relative path for storage
            let coversPath = "/books/covers"
            let fullCoversPath = getDocumentsDirectory().path + coversPath
            
            try? FileManager.default.createDirectory(atPath: fullCoversPath,
                                                     withIntermediateDirectories: true)
            
            let filename = URL(string: book.cover)?.lastPathComponent ?? "\(book.id).jpg"
            let relativePath = "\(coversPath)/\(filename)"
            let fullPath = getFullPath(from: relativePath)
            
            // Remove existing file if present
            try? FileManager.default.removeItem(atPath: fullPath)
            
            if FileManager.default.createFile(atPath: fullPath, contents: data) {
                // Store only the relative path
                book.localImgURL = relativePath
                modelContextSave()
                print("Saved image with relative path: \(relativePath)")
                return data
            }
        } catch {
            print("Error in download process: \(error)")
        }
        
        return nil
    }
    
    func clearAllImages() {
        let coversPath = getDocumentsDirectory().path + "/books/covers"
        
        do {
            try FileManager.default.removeItem(atPath: coversPath)
            
            let descriptor = FetchDescriptor<Book>()
            if let books = try? modelContext.fetch(descriptor) {
                for book in books {
                    book.localImgURL = nil
                }
                modelContextSave()
            }
        } catch {
            print("error deleting images \(error)")
        }
    }
}

