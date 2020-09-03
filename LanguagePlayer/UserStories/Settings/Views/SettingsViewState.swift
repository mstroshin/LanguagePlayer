struct SettingsViewState: Equatable {
    let isPremium: Bool
    let selectedSourceLanguageName: String
    let selectedTargetLanguageName: String
    
    init(appState: AppState) {
        self.isPremium = appState.purchasingState.isPremium
        self.selectedSourceLanguageName = appState.settings.selectedSourceLanguage.name
        self.selectedTargetLanguageName = appState.settings.selectedTargetLanguage.name
    }
}
