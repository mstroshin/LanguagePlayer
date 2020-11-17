import Foundation
import RealmSwift
import DifferenceKit

class TranslationEntity: Object {
    @objc dynamic var id: ID = UUID().uuidString
    @objc dynamic var source: String = ""
    @objc dynamic var target: String = ""
    @objc dynamic var isAddedToDictionary: Bool = false
    let owners = LinkingObjects(fromType: VideoEntity.self, property: "translations")
    
    override class func primaryKey() -> String? { "id" }
}

extension TranslationEntity: Differentiable {
    
}
