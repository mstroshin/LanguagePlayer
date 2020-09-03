struct SettingsState: Codable {
    //MARK: - Languages
    var selectedSourceLanguage = Language(code: "en", name: "English")
    var selectedTargetLanguage = Language(code: "ru", name: "Русский")
    
    var availableLanguages = [Language]()
    
    //MARK: -
}

struct Language: Codable {
    let code: String
    let name: String
}
