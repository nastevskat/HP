import Foundation
import SwiftData

protocol Persistable {
    var id: Int { get }
    var localImgURL: String? { get set }
    var title: String? { get set }
    var fullName: String? { get set }
    var image: String { get set }
    var isFavorite: Bool { get set }
}

@Model
final class Book: Codable, Persistable {
    var localImgURL: String?
    var title: String?
    var fullName: String?
    var image: String
    
    
    @Attribute(.unique) var id: Int
    var number: Int
    var originalTitle: String
    var releaseDate: String
    var desc: String
    var pages: Int
    var isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "index"
        case number
        case title
        case originalTitle
        case releaseDate
        case desc = "description"
        case pages
        case image = "cover"
        case isFavorite
        case localImgURL
        case fullName
    }
    
    init(id: Int, number: Int, title: String? = nil, originalTitle: String, releaseDate: String, desc: String, pages: Int, image: String, isFavorite: Bool = false, localImgURL: String? = nil, fullName: String? = nil) {
        self.id = id
        self.number = number
        self.title = title
        self.originalTitle = originalTitle
        self.releaseDate = releaseDate
        self.desc = desc
        self.pages = pages
        self.image = image
        self.isFavorite = isFavorite
        self.localImgURL = localImgURL
        self.fullName = fullName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        number = try container.decode(Int.self, forKey: .number)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        originalTitle = try container.decode(String.self, forKey: .originalTitle)
        releaseDate = try container.decode(String.self, forKey: .releaseDate)
        desc = try container.decode(String.self, forKey: .desc)
        pages = try container.decode(Int.self, forKey: .pages)
        image = try container.decode(String.self, forKey: .image)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        localImgURL = try container.decodeIfPresent(String.self, forKey: .localImgURL)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(number, forKey: .number)
        try container.encode(title, forKey: .title)
        try container.encode(originalTitle, forKey: .originalTitle)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(desc, forKey: .desc)
        try container.encode(pages, forKey: .pages)
        try container.encode(image, forKey: .image)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(localImgURL, forKey: .localImgURL)
        try container.encode(fullName, forKey: .fullName)
    }
}
