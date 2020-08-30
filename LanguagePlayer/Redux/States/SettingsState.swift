struct SettingsState: Codable {
    //MARK: - Languages
    var selectedSourceLanguage = Language(code: "en", name: "english")
    var selectedTargetLanguage = Language(code: "ru", name: "русский")
    
    var availableLanguages = [Language]()
    
    //MARK: -
}

struct Language: Codable {
    let code: String
    let name: String
}
