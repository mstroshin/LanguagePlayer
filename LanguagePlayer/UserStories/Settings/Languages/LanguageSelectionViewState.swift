struct LanguageSelectionViewState {
    let languages: [Language]
    let selectedSourceLanguageCode: String
    let selectedTargetLanguageCode: String
    
    init(appState: AppState) {
        self.languages = appState.settings.availableLanguages
        self.selectedSourceLanguageCode = appState.settings.selectedSourceLanguage.code
        self.selectedTargetLanguageCode = appState.settings.selectedTargetLanguage.code
    }
}
