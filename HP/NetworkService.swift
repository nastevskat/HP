import Foundation
import SwiftData

enum AppError: Error {
    case invalidURL
    case endOfList
    case networkError(Error)
    case dataProcessingError(Error)
    case decodingError(Error)
    case databaseError(Error)
    case unknownError(Error)
    
    var errorMessage: String  {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again later."
        case .endOfList:
            return "You've reached the end of the list."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .dataProcessingError(let error):
            return "Data processing error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    
    func printErrorMessage() -> String {
            return self.errorMessage
    }
}

class NetworkService {
    var errorMessage: String?
    var showError: Bool = false
    
    func loadData<T: Decodable>(from url: URL) async throws -> T {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch let appError as AppError {
            throw appError
        }
    }
}
