import Foundation
import SwiftData

enum APIEndpoint {
    case book(max: Int, pageToFetch: Int)
    case character(max: Int, pageToFetch: Int)
    
    private var baseURL: String {
        "https://potterapi-fedeperin.vercel.app/en"
    }
    
    var url: URL? {
        switch self {
        case .book(let max, let pageToFetch):
            return  URL(string:baseURL + "/books?max=\(max)&page=\(pageToFetch)")
        case .character(let max, let pageToFetch):
            return URL(string: baseURL + "/characters?max=\(max)&page=\(pageToFetch)")
        }
    }
}

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
    
    func loadData<T: Decodable>(for endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
               throw AppError.invalidURL
           }
           
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch let error as DecodingError {
            throw AppError.decodingError(error)
        } catch let error as URLError {
            throw AppError.networkError(error)
        } catch {
            throw AppError.unknownError(error)
        }
    }
    
    func downloadImage(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        print("Downloaded \(data.count) bytes")
        return data
    }

}
