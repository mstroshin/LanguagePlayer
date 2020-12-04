import Foundation
import RealmSwift
import DifferenceKit

class FavoriteSubtitle: Object {
    @objc dynamic var id: ID = UUID().uuidString
    @objc dynamic var first: String = ""
    @objc dynamic var second: String = ""
    let owners = LinkingObjects(fromType: VideoEntity.self, property: "favoriteSubtitles")
    
    override class func primaryKey() -> String? { "id" }
}

extension FavoriteSubtitle: Differentiable {
    
}
