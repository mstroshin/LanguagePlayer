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
        
    struct SaveTranslationToDictionary: Action {
        let source: String
        let target: String
        let videoID: ID
        let fromMilliseconds: TimeInterval
        let toMilliseconds: TimeInterval
    }
    
    struct AddTranslationToHistory: Action {
        let source: String
        let target: String
        let videoID: ID
        let fromMilliseconds: TimeInterval
        let toMilliseconds: TimeInterval
    }
    
    struct RemoveVideo: Action {
        let id: ID
    }
    
}

struct UploadedFile {
    let fileName: String
    let temporaryDataPath: String
}
