import Foundation

func videosListStateReducer(state: VideosListState, action: Action) -> VideosListState {
    var state = state
    
    switch action {
    case let action as VideosListStateActions.AddedVideo:
        let video = VideoState(
            id: 0,
            title: "",
            url: action.url,
            sourceSubtitleUrl: nil,
            targetSubtitleUrl: nil
        )
        state.videos.append(video)
    default:
        break
    }
    
    return state
}
