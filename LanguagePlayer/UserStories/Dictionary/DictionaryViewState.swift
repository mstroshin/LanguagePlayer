import Foundation
import DifferenceKit

struct DictionaryViewState {
    let translations: [TranslationViewState]
    
    init(appState: AppState) {
        self.translations = appState.translations.map { translation in
            let video = appState.videos.first { $0.id == translation.videoId }!
            return TranslationViewState(state: translation, videoTitle: video.title)
        }
    }
}

struct TranslationViewState {
    let id: ID
    let source: String
    let target: String
    let fromMilliseconds: TimeInterval
    let toMilliseconds: TimeInterval
    let videoTitle: String
    
    init(state: TranslationState, videoTitle: String) {
        self.id = state.id
        self.source = state.source
        self.target = state.target
        self.fromMilliseconds = state.fromMilliseconds
        self.toMilliseconds = state.toMilliseconds
        self.videoTitle = videoTitle
    }
}

extension TranslationViewState: Differentiable {
    typealias DifferenceIdentifier = ID?

    var differenceIdentifier: ID? {
        return id
    }
    
    func isContentEqual(to source: TranslationViewState) -> Bool {
        self.id == source.id
    }
}
