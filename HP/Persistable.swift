import Foundation

protocol Persistable {
    var id: Int { get }
    var localImgURL: String? { get set }
    var title: String? { get set }
    var fullName: String? { get set }
    var image: String { get set }
    var isFavorite: Bool { get set }
}
