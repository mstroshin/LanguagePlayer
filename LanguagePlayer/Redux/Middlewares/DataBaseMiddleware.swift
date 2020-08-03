import Foundation

struct DataBaseMiddleware: Middleware {
    
    func execute(getState: StateSupplier, action: Action, dispatch: @escaping DispatchFunction) {
        
        switch action {
        case _ as AppStateActions.LoadAppState:
            if let loadedState = UserDefaultsDataStore.loadAppState() {
                dispatch(AppStateActions.LoadedAppState(state: loadedState))
            }
        case _ as AppStateActions.SaveAppState:
            guard let state = getState() as? AppState else { return }
            UserDefaultsDataStore.save(appState: state)
        case let action as AppStateActions.SaveVideo:
            if let videoUrl = LocalDiskStore().save(data: action.data) {
                dispatch(VideosListStateActions.AddedVideo(url: videoUrl))
            } else {
                print("Video was not saved")
            }
        default:
            break
        }
        
    }
    
}
