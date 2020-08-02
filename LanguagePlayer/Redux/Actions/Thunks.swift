import Foundation

//let loadAppState = Thunk<AppState> { dispatch, getState in
//    let loadedState = UserDefaultsDataStore.loadAppState()
//    dispatch(AppStateAction.loadState(loadedState ?? AppState()))
//}
//
//let saveAppState = Thunk<AppState> { dispatch, getState in
//    guard let state = getState() else { return }
//    UserDefaultsDataStore.save(appState: state)
//}
//
//func uploadedVideo(data: NSData) -> Thunk<AppState> {
//    Thunk<AppState> { dispatch, getState in
//        if let videoUrl = LocalDiskStore().save(data: data) {
//            dispatch(VideosListStateAction.addVideo(videoUrl))
//        } else {
//            print("Video was not saved")
//        }
//    }
//}

