import Foundation
import RealmSwift

class FavoriteSubtitle: Object {
    @objc dynamic var id: ID = UUID().uuidString
    @objc dynamic var first: String = ""
    @objc dynamic var second: String = ""
    @objc dynamic var fromTime: Milliseconds = 0
    let owners = LinkingObjects(fromType: VideoEntity.self, property: "favoriteSubtitles")
    
    override class func primaryKey() -> String? { "id" }
}
