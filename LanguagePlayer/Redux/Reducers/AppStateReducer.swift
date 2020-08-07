import ReSwift
import Foundation

func appStateReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    
    switch action {
    case let action as AppStateActions.LoadedAppState:
        return action.state
    case let action as AppStateActions.AddedVideo:
        let video = VideoState(
            id: UUID().uuidString,
            title: action.videoTitle,
            savedFileName: action.savedFileName
        )
        state.videos.append(video)
    case let action as AppStateActions.SaveTranslation:
        let translation = TranslationState(
            id: UUID().uuidString,
            videoId: action.videoID,
            source: action.source,
            target: action.target,
            fromMilliseconds: action.fromMilliseconds,
            toMilliseconds: action.toMilliseconds
        )
        state.translations.append(translation)
    default:
        break
    }
    
    return state
}
