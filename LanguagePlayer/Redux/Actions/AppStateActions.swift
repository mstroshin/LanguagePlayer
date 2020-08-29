import Foundation
import ReSwift

struct AppStateActions {
    
    //MARK: - App State Persistence
    struct LoadAppState: Action {}
    
    struct LoadedAppState: Action {
        let state: AppState
    }
    
    struct SaveAppState: Action {}
    
    //MARK: - Video
    struct AddedVideo: Action {
        let videoFileName: String
        let sourceSubtitleFileName: String?
        let targetSubtitleFileName: String?
        let savedInDirectoryName: String
    }
    
    struct SaveVideo: Action {
        let video: UploadedFile
        let sourceSubtitle: UploadedFile?
        let targetSubtitle: UploadedFile?
    }
    
    struct RemoveVideo: Action {
        let id: ID
        let removeAllCards: Bool
    }
    
    //MARK: - Translation Favorites
    struct ToogleCurrentTranslationFavorite: Action {}
    
    struct AddTranslationToHistory: Action {
        let data: TranslationModel
    }
    
    //MARK: - Subtitle translation
    struct Translate: Action {
        let source: String
        let videoID: ID
        let fromTime: Milliseconds
        let toTime: Milliseconds
    }
    
    struct Translating: Action {}
    
    struct TranslationResult: Action {
        let data: TranslationModel?
        let error: Error?
    }
    
    struct ClearCurrentTranslation: Action {}
    
    struct RemoveTranslation: Action {
        let id: ID
    }
    
    //MARK: - Server
    struct ServerStarted: Action {
        var webServerIPAddress: String?
        var webServerAddress: String?
    }
    
}

struct UploadedFile {
    let fileName: String
    let temporaryDataPath: String
}

struct TranslationModel {
    let source: String
    let target: String
    let videoID: ID
    let fromTime: Milliseconds
    let toTime: Milliseconds
}
