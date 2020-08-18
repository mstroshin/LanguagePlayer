import Foundation

struct VideoPlayerViewState {
    let tranlsation: TranslationViewState?
    
    init(appState: AppState) {
        guard let translation = appState.currentTranslation else {
            self.tranlsation = nil
            return
        }
        
        let isAddedInDictionary = appState.translations.contains { $0.source == translation.source }
        self.tranlsation = TranslationViewState(
            translation: translation.target,
            isAddedInDictionary: isAddedInDictionary
        )
    }
}
