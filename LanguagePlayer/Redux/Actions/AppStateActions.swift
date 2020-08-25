import Foundation
import ReSwift

struct AppStateActions {
    
    struct LoadAppState: Action {}
    
    struct LoadedAppState: Action {
        let state: AppState
    }
    
    struct SaveAppState: Action {}
    
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
    
    struct ToogleCurrentTranslationFavorite: Action {}
    
    struct AddTranslationToHistory: Action {
        let data: TranslationModel
    }
    
    struct RemoveVideo: Action {
        let id: ID
    }
    
    struct Translate: Action {
        let source: String
        let videoID: ID
        let fromTime: Milliseconds
        let toTime: Milliseconds
    }
    
    struct AddTranslation: Action {
        let data: TranslationModel
    }
    
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
