import Foundation
import SwiftData

enum AppError: Error {
    case invalidURL
    case endOfList
    case networkError(Error)
    case dataProcessingError(Error)
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again later."
        case .endOfList:
            return "You've reached the end of the list"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .dataProcessingError(let error):
            return "Data processing error: \(error.localizedDescription)"
        }
    }
}


class NetworkService {
    var errorMessage: String?
    var showError: Bool = false
    
    func loadData<T: Decodable>(from url: URL) async throws -> [T] {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([T].self, from: data)
            return decodedData
            
        } catch {
            throw AppError.networkError(error)
        }
    }
    
    func handleError(_ error: Error) {
        if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    errorMessage = "No internet connection. Please try again."
                case .timedOut:
                    errorMessage = "Request timed out. Please try again."
                default:
                    errorMessage = "Network error: \(urlError.localizedDescription)"
                }
            } else if let error = error as? AppError {
                errorMessage = error.errorMessage
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
            showError = true
    }
}
