import ReSwift

func settingsReducer(action: SettingsActions, state: AppState) -> AppState {
    var state = state
    
    switch action {
        case let action as SelectSourceLanguage:
            state.settings.selectedSourceLanguage = action.language
        
        case let action as SelectTargetLanguage:
            state.settings.selectedTargetLanguage = action.language
        
        default:
            break
    }
    
    return state
}
