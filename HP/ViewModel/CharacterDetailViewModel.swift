import Foundation
import Observation
import SwiftData

@Observable class CharacterDetailViewModel {
    var character: Character
    private let fileManagerHelper: FileManagerHelper
    
    init(character: Character, fileManagerHelper: FileManagerHelper) {
        self.character = character
        self.fileManagerHelper = fileManagerHelper
    }
    
    func loadImageData() async -> Data? {
        return await fileManagerHelper.loadImage(for: &character)
        
    }
}
