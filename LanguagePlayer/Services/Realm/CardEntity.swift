import Foundation
import RealmSwift

class CardEntity: Object {
    @objc dynamic var id: ID = UUID().uuidString
    @objc dynamic var firstSubtitleText: String = ""
    @objc dynamic var secondSubtitleText: String = ""
    @objc dynamic var videoTitle: String?
    let owners = LinkingObjects(fromType: VideoEntity.self, property: "favoriteCards")
    
    override class func primaryKey() -> String? { "id" }
}

extension CardEntity {
    
    func toDTO() -> Card {
        Card(
            id: id,
            firstSubtitleText: firstSubtitleText,
            secondSubtitleText: secondSubtitleText,
            videoTitle: owners.first?.name
        )
    }
    
    static func from(dto: Card) -> CardEntity {
        let card = CardEntity()
        card.id = dto.id
        card
        
        return card
    }
    
}
