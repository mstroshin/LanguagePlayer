import ReSwift

protocol SettingsActions: Action {}

struct SelectSourceLanguage: SettingsActions  {
    let language: Language
}

struct SelectTargetLanguage: SettingsActions  {
    let language: Language
}
