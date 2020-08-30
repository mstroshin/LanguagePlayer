import ReSwift

func videoPlayerReducer(action: VideoPlayerActions, state: AppState) -> AppState {
    var state = state
    
    switch action {
        case _ as ToogleCurrentTranslationFavorite:
            guard let currentTranslation = state.currentTranslation else { break }
            if let index = state.translations.firstIndex(where: { $0.source == currentTranslation.source }) {
                state.translations.remove(at: index)
            } else {
                state.translations.append(currentTranslation)
            }
        
        case let action as AddTranslationToHistory:
            let translation = TranslationState(from: action.data)
            state.translationsHistory.append(translation)
        
        case _ as Translating:
            state.translating = true
        
        case let action as TranslationResult:
            state.translating = false
            if let data = action.data {
                let translation = TranslationState(from: data)
                state.currentTranslation = translation
            } else if let _ = action.error {
                state.currentTranslation = nil
            }
        
        case _ as ClearCurrentTranslation:
            state.currentTranslation = nil
        
        default:
            break
    }
    
    return state
}
