import ReSwift

func settingsReducer(action: SettingsActions, state: AppState) -> AppState {
    var state = state
    
    switch action {
        case let action as SelectSourceLanguage:
            state.settings.selectedSourceLanguage = action.language
        
        case let action as SelectTargetLanguage:
            state.settings.selectedTargetLanguage = action.language
        
        case let action as SaveAvailableLanguages:
            state.settings.availableLanguages = action.languages.map {
                Language(code: $0.code, name: $0.name.capitalized)
            }
        
        default:
            break
    }
    
    return state
}
