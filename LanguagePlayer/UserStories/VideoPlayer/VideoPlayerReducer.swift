import ReSwift

func videoPlayerReducer(action: VideoPlayerActions, state: AppState) -> AppState {
    var state = state
    
    switch action {
        case _ as ToogleCurrentTranslationFavorite:
            if case .success(let data) = state.translationStatus.result,
                let currentTranslation = data as? TranslationState {
                if let index = state.translations.firstIndex(where: { $0.source == currentTranslation.source }) {
                    state.translations.remove(at: index)
                } else {
                    state.translations.append(currentTranslation)
                }
            }
        
        case let action as AddTranslationToHistory:
            let translation = TranslationState(from: action.data)
            state.translationsHistory.append(translation)
        
        case _ as Translating:
            state.translationStatus.isLoading = true
        
        case let action as TranslationResult:
            state.translationStatus.isLoading = false
            if let data = action.data {
                let translation = TranslationState(from: data)
                state.translationStatus.result = .success(translation)
            } else if let error = action.error {
                state.translationStatus.result = .failure(error)
            }
        
        case _ as ClearCurrentTranslation:
            state.translationStatus.result = nil
        
        default:
            break
    }
    
    return state
}
