import Foundation
import SwiftData

@Model
class Book: Codable {
    @Attribute(.unique) var id: Int
    var number: Int
    var title: String
    var originalTitle: String
    var releaseDate: String
    var desc: String
    var pages: Int
    var cover: String
    var isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "index"
        case number
        case title
        case originalTitle
        case releaseDate
        case desc = "description"
        case pages
        case cover
        case isFavorite
    }
    
    init(id: Int, number: Int, title: String, originalTitle: String, releaseDate: String, desc: String, pages: Int, cover: String, isFavorite: Bool = false) {
        self.id = id
        self.number = number
        self.title = title
        self.originalTitle = originalTitle
        self.releaseDate = releaseDate
        self.desc = desc
        self.pages = pages
        self.cover = cover
        self.isFavorite = isFavorite
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        number = try container.decode(Int.self, forKey: .number)
        title = try container.decode(String.self, forKey: .title)
        originalTitle = try container.decode(String.self, forKey: .originalTitle)
        releaseDate = try container.decode(String.self, forKey: .releaseDate)
        desc = try container.decode(String.self, forKey: .desc)
        pages = try container.decode(Int.self, forKey: .pages)
        cover = try container.decode(String.self, forKey: .cover)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
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
        try container.encode(cover, forKey: .cover)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}
