import Foundation
import ReSwift
import ReSwift_Thunk

struct AppStateActions {
    
    struct LoadAppState: Action {}
    
    struct LoadedAppState: Action {
        let state: AppState
    }
    
    struct SaveAppState: Action {}
    
    struct AddedVideo: Action {
        let videoTitle: String
        let savedFileName: String
    }
    
    struct SaveVideo: Action {
        let video: UploadedFile
        let sourceSubtitle: UploadedFile
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
    let title: String
    let data: Data
}
