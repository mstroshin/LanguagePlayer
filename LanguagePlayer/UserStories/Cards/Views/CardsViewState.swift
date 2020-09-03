import Foundation
import DifferenceKit

struct CardsViewState: Equatable {
    let cards: [CardItemState]
    
    init(appState: AppState) {
        self.cards = appState.translations.map { translation in
            let video = appState.videos.first { $0.id == translation.videoId }
            return CardItemState(state: translation, fileName: video?.fileName)
        }
    }
}

struct CardItemState: Equatable {
    let id: ID
    let source: String
    let target: String
    let fromTime: Milliseconds
    let toTime: Milliseconds
    let videoTitle: String?
    let videoId: ID?
    
    init(state: TranslationState, fileName: String?) {
        self.id = state.id
        self.source = state.source
        self.target = state.target
        self.fromTime = state.fromTime
        self.toTime = state.toTime
        self.videoTitle = fileName?.components(separatedBy: ".").first
        self.videoId = fileName == nil ? nil : state.videoId
    }
}

extension CardItemState: Differentiable {
    typealias DifferenceIdentifier = ID?

    var differenceIdentifier: ID? {
        return id
    }
    
    func isContentEqual(to source: CardItemState) -> Bool {
        self.id == source.id && self.videoId == source.videoId
    }
}
