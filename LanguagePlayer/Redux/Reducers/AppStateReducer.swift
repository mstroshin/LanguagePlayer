func appStateReducer(state: AppState, action: Action) -> AppState {
    var state = state
    
    switch action {
    case let action as AppStateActions.LoadedAppState:
        return action.state
    default:
        state.videos = videosListStateReducer(state: state.videos, action: action)
    }
    
    return state
}
