import Foundation
import DifferenceKit

struct DictionaryViewState {
    let translations: [TranslationViewState]
    
    init(appState: AppState) {
        self.translations = appState.translations.map(TranslationViewState.init)
    }
}

struct TranslationViewState {
    let id: ID
    let videoId: ID
    let source: String
    let target: String
    let fromMilliseconds: TimeInterval
    let toMilliseconds: TimeInterval
    
    init(state: TranslationState) {
        self.id = state.id
        self.videoId = state.videoId
        self.source = state.source
        self.target = state.target
        self.fromMilliseconds = state.fromMilliseconds
        self.toMilliseconds = state.toMilliseconds
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
