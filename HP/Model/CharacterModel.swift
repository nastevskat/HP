import Foundation
import SwiftData

@Model
class Character: Codable {
    @Attribute(.unique) var id: Int
    var fullName: String
    var nickname: String
    var hogwartsHouse: String
    var interpretedBy: String
    var children: [String]
    var image: String
    var birthdate: String
    
    enum CodingKeys: String, CodingKey {
        case id = "index"
        case fullName, nickname, hogwartsHouse, interpretedBy, children, image, birthdate
    }
    
    init(id: Int, fullName: String, nickname: String, hogwartsHouse: String, interpretedBy: String, children: [String], image: String, birthdate: String) {
        self.id = id
        self.fullName = fullName
        self.nickname = nickname
        self.hogwartsHouse = hogwartsHouse
        self.interpretedBy = interpretedBy
        self.children = children
        self.image = image
        self.birthdate = birthdate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = 
    }
}


