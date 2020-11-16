import Foundation
import DifferenceKit

struct CardViewEntity {
    let id: ID
    let source: String
    let target: String
    let isAddedToDictionary: Bool
    let videoTitle: String?
    
    init(translation: TranslationEntity) {
        self.id = translation.id
        self.source = translation.source
        self.target = translation.target
        self.isAddedToDictionary = translation.isAddedToDictionary
        self.videoTitle = translation.owners.last?.fileName
    }
}

extension CardViewEntity: Differentiable {
    var differenceIdentifier: ID { id }
    
    func isContentEqual(to source: CardViewEntity) -> Bool {
        self.id == source.id
    }
}
