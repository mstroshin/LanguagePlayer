import ReSwift

func settingsReducer(action: SettingsActions, state: AppState) -> AppState {
    var state = state
    
    switch action {
        case let action as SelectSourceLanguage:
            state.settings.selectedSourceLanguage = action.language
        
        case let action as SelectTargetLanguage:
            state.settings.selectedTargetLanguage = action.language
        
        case let action as SaveAvailableLanguages:
            state.settings.availableLanguages = action.languages.compactMap({
                if let name = $0.name {
                    return Language(code: $0.code, name: name.capitalized)
                } else {
                    return nil
                }
            })
        
        default:
            break
    }
    
    return state
}
