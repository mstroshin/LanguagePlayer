import Foundation
import ReSwift
import ReSwift_Thunk

struct AppStateActions {
        
    static let loadAppState = Thunk<AppState> { dispatch, getState in
        if let loadedState = UserDefaultsDataStore.loadAppState() {
            dispatch(AppStateActions.LoadedAppState(state: loadedState))
        }
    }
        
    static let saveAppState = Thunk<AppState> { dispatch, getState in
        guard let state = getState() else { return }
        UserDefaultsDataStore.save(appState: state)
    }
    
    struct LoadedAppState: Action {
        let state: AppState
    }
    
    struct AddedVideo: Action {
        let videoTitle: String
        let savedFileName: String
    }
    
    static func saveVideo(data: UploadedVideo) -> Thunk<AppState> {
        return Thunk<AppState> { dispatch, getState in
            let fileName = UUID().uuidString
            if LocalDiskStore().save(data: data.videoData, fileName: fileName + ".mp4") &&
                LocalDiskStore().save(data: data.sourceSubtitleData, fileName: fileName + ".srt") {
                let action = AppStateActions.AddedVideo(
                    videoTitle: data.videoTitle,
                    savedFileName: fileName
                )
                dispatch(action)
                store.dispatch(AppStateActions.saveAppState)
            } else {
                print("Video was not saved")
            }
        }
    }
    
}
