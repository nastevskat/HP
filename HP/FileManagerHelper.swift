import Foundation
import SwiftData

class FileManagerHelper {
    let modelContext: ModelContext
    let networkService: NetworkService
    
    init(modelContext: ModelContext, networkService: NetworkService) {
        self.modelContext = modelContext
        self.networkService = networkService
    }
    
    private func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getFullPath(from relativePath: String) -> String {
        return getDocumentsDirectory().path + relativePath
    }
    
    private func checkLocalImage<T: Persistable>(for item: inout T) -> Data? {
        if let relativePath = item.localImgURL {
            let fullPath = getFullPath(from: relativePath)
            print("Checking full path")
            
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
                    print("Successfully read \(data.count) bytes from cache")
                    if !data.isEmpty {
                        return data
                    }
                } catch {
                    print("Error reading file: \(error.localizedDescription)")
                }
            }
        }
        return nil
    }
    
    private func saveImage<T: Persistable>(data: Data, for item: inout T) -> Bool {
        let imagesPath = "/images"
        let fullImagesPath = getDocumentsDirectory().path + imagesPath
        
        try? FileManager.default.createDirectory(atPath: fullImagesPath, withIntermediateDirectories: true)
        
        let fileName = URL(string: item.image)?.lastPathComponent ?? "\(item.id).jpg"
        let relativePath = "\(imagesPath)/\(fileName)"
        let fullPath = getFullPath(from: relativePath)
        
        try? FileManager.default.removeItem(atPath: fullPath)
        
        if FileManager.default.createFile(atPath: fullPath, contents: data) {
            item.localImgURL = relativePath
            modelContextSave()
            print("Saved image with relative path: \(relativePath)")
            return true
        }
        return false
    }
    
    func loadImage<T: Persistable>(for item: inout T) async -> Data? {
        print("Starting loadImage for item ID: \(item.id)")
        
        if let localData = checkLocalImage(for: &item) {
            return localData
        }
        guard let url = URL(string: item.image) else {
            print("invalid image url")
            return nil
        }
        do {
            let data = try await networkService.downloadImage(from: url)
            if saveImage(data: data, for: &item) {
                return data
            }
        } catch {
            print("error downloading picture")
        }
        return nil
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
