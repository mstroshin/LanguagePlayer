import Foundation
import DifferenceKit

struct CardViewEntity {
    let id: ID
    let source: String
    let target: String
    let videoTitle: String?
    
    init(translation: FavoriteSubtitle) {
        self.id = translation.id
        self.source = translation.first
        self.target = translation.second
        self.videoTitle = translation.owners.last?.fileName
    }
}

extension CardViewEntity: Differentiable {
    var differenceIdentifier: ID { id }
    
    func isContentEqual(to source: CardViewEntity) -> Bool {
        self.id == source.id
    }
}
