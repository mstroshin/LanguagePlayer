import ReSwift

protocol VideoPlayerActions: Action {}

struct TranslationModel {
    let source: String
    let target: String
    let videoID: ID
    let fromTime: Milliseconds
    let toTime: Milliseconds
}

//MARK: - Translation Favorites
struct ToogleCurrentTranslationFavorite: VideoPlayerActions {}

struct AddTranslationToHistory: VideoPlayerActions {
    let data: TranslationModel
}

//MARK: - Subtitle translation
struct GetAvailableLanguages: VideoPlayerActions {}

struct SaveAvailableLanguages: VideoPlayerActions {
    let languages: [LanguageAPIDTO]
}

struct Translate: VideoPlayerActions {
    let source: String
    let videoID: ID
    let fromTime: Milliseconds
    let toTime: Milliseconds
}

struct Translating: VideoPlayerActions {}

struct TranslationResult: VideoPlayerActions {
    let data: TranslationModel?
    let error: Error?
}

struct ClearCurrentTranslation: VideoPlayerActions {}
