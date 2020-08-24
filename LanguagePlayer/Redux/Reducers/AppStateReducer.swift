import ReSwift
import Foundation

func appStateReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    state.navigation = navigationStateReducer(action: action, state: state.navigation)
    
    switch action {
    case let action as AppStateActions.LoadedAppState:
        return action.state
    case let action as AppStateActions.AddedVideo:
        let video = VideoState(
            id: UUID().uuidString,
            savedInDirectoryName: action.savedInDirectoryName,
            fileName: action.videoFileName,
            sourceSubtitleFileName: action.sourceSubtitleFileName,
            targetSubtitleFileName: action.targetSubtitleFileName
        )
        state.videos.append(video)
    case _ as AppStateActions.ToogleCurrentTranslationFavorite:
        guard let currentTranslation = state.currentTranslation else { break }
        if let index = state.translations.firstIndex(where: { $0.source == currentTranslation.source }) {
            state.translations.remove(at: index)
        } else {
            state.translations.append(currentTranslation)
        }
    case let action as AppStateActions.AddTranslationToHistory:
        let translation = TranslationState(from: action.data)
        state.translationsHistory.append(translation)
    case let action as AppStateActions.RemoveVideo:
        state.videos.removeAll(where: { $0.id == action.id })
    case let action as AppStateActions.AddTranslation:
        let translation = TranslationState(from: action.data)
        state.currentTranslation = translation
    case let action as AppStateActions.ServerStarted:
        state.webServerAddress = action.webServerAddress
        state.webServerIPAddress = action.webServerIPAddress
    default:
        break
    }
    
    return state
}
