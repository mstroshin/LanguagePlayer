import ReSwift

func videosListReducer(action: VideosListActions, state: AppState) -> AppState {
    var state = state
    
    switch action {
        case let action as AddedVideo:
            let video = VideoState(
                id: UUID().uuidString,
                savedInDirectoryName: action.savedInDirectoryName,
                fileName: action.videoFileName,
                sourceSubtitleFileName: action.sourceSubtitleFileName,
                targetSubtitleFileName: action.targetSubtitleFileName
            )
            state.videos.append(video)
        
        case let action as RemoveVideo:
            state.videos.removeAll(where: { $0.id == action.id })
            if action.removeAllCards {
                state.translations.removeAll(where: { $0.videoId == action.id })
            }
        
        default:
            break
    }
    
    return state
}
