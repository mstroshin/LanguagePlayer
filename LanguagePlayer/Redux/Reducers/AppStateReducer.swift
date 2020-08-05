import ReSwift

func appStateReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    
    switch action {
    case let action as AppStateActions.LoadedAppState:
        return action.state
    case let action as AppStateActions.AddedVideo:
        let video = VideoState(
            id: state.videos.count,
            title: action.videoTitle,
            savedFileName: action.savedFileName
        )
        state.videos.append(video)
    default:
        break
    }
    
    return state
}
