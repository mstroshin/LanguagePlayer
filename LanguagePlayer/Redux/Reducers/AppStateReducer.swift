func appStateReducer(action: Action, state: AppState) -> AppState {
    var state = state
    
    guard let appStateAction = action as? AppStateAction else {
        state.videos = VideosListState.reducer(action: action, state: state.videos)
        return state
    }
    
    switch appStateAction {
    case .loadState(let loadedState):
        return loadedState
    }
    
    //        return state
}
