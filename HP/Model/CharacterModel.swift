import Foundation
import SwiftData

@Model
class Character: Codable, Persistable {
    var isFavorite: Bool
    
    @Attribute(.unique) var id: Int
    var fullName: String?
    var nickname: String
    var hogwartsHouse: String
    var interpretedBy: String
    var children: [String]
    var image: String
    var birthdate: String
    var localImgURL: String?
    var title: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "index"
        case fullName, nickname, hogwartsHouse, interpretedBy, children, image, birthdate, localImgURL, title, isFavorite
    }
    
    init(id: Int, fullName: String? = nil, nickname: String, hogwartsHouse: String, interpretedBy: String, children: [String], image: String, birthdate: String, localImgURL: String? = nil, title: String? = nil, isFavorite: Bool = false) {
        self.id = id
        self.fullName = fullName
        self.nickname = nickname
        self.hogwartsHouse = hogwartsHouse
        self.interpretedBy = interpretedBy
        self.children = children
        self.image = image
        self.birthdate = birthdate
        self.localImgURL = localImgURL
        self.title = title
        self.isFavorite = isFavorite
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        nickname = try container.decode(String.self, forKey: .nickname)
        hogwartsHouse = try container.decode(String.self, forKey: .hogwartsHouse)
        interpretedBy = try container.decode(String.self, forKey: .interpretedBy)
        children = try container.decode([String].self, forKey: .children)
        image = try container.decode(String.self, forKey: .image)
        birthdate = try container.decode(String.self, forKey: .birthdate)
        localImgURL = try container.decodeIfPresent(String.self, forKey: .localImgURL)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(hogwartsHouse, forKey: .hogwartsHouse)
        try container.encode(interpretedBy, forKey: .interpretedBy)
        try container.encode(children, forKey: .children)
        try container.encode(image, forKey: .image)
        try container.encode(birthdate, forKey: .birthdate)
        try container.encode(localImgURL, forKey: .localImgURL)
        try container.encode(title, forKey: .title)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}
