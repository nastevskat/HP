import Foundation
import Observation
import SwiftData

@Observable class BookDetailViewModel {
    var book: Book
    private let fileManagerHelper: FileManagerHelper
    
    init(book: Book, fileManagerHelper: FileManagerHelper) {
        self.book = book
        self.fileManagerHelper = fileManagerHelper
    }
    
    func loadImageData() async -> Data? {
        return await fileManagerHelper.loadImage(for: &book)
        
    }
    
    func toggleFavorite() {
        book.isFavorite.toggle()
        fileManagerHelper.modelContextSave()
    }
}
