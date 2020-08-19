import Foundation
import DifferenceKit

struct DictionaryViewState {
    let translations: [TranslationViewState]
    
    init(appState: AppState) {
        self.translations = appState.translations.map { translation in
            let video = appState.videos.first { $0.id == translation.videoId }!
            return TranslationViewState(state: translation, fileName: video.fileName)
        }
    }
    
    struct TranslationViewState {
        let id: ID
        let source: String
        let target: String
        let fromMilliseconds: TimeInterval
        let toMilliseconds: TimeInterval
        let videoTitle: String
        let videoId: ID
        
        init(state: TranslationState, fileName: String) {
            self.id = state.id
            self.source = state.source
            self.target = state.target
            self.fromMilliseconds = state.fromMilliseconds
            self.toMilliseconds = state.toMilliseconds
            self.videoTitle = fileName.components(separatedBy: ".").first!
            self.videoId = state.videoId
        }
    }

    
}

extension DictionaryViewState.TranslationViewState: Differentiable {
    typealias DifferenceIdentifier = ID?

    var differenceIdentifier: ID? {
        return id
    }
    
    func isContentEqual(to source: DictionaryViewState.TranslationViewState) -> Bool {
        self.id == source.id
    }
}
