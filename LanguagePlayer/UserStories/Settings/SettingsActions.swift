import ReSwift

protocol SettingsActions: Action {}

struct SaveAvailableLanguages: SettingsActions {
    let languages: [LanguageAPIDTO]
}

struct SelectSourceLanguage: SettingsActions  {
    let language: Language
}

struct SelectTargetLanguage: SettingsActions  {
    let language: Language
}

struct DownloadOfflineModel: SettingsActions {}
