import ReSwift
import Foundation

func appStateReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    state.navigation = navigationStateReducer(action: action, state: state.navigation)
    
    switch action {
        case let action as VideosListActions:
            return videosListReducer(action: action, state: state)
            
        case let action as VideoPlayerActions:
            return videoPlayerReducer(action: action, state: state)
            
        case let action as CardsActions:
            return cardsReducer(action: action, state: state)
            
        case let action as SettingsActions:
            return settingsReducer(action: action, state: state)
        
        case let action as PurchasingActions:
            state.purchasing = purchasingReducer(action: action, state: state.purchasing)
            
        default:
            break
    }
    
    switch action {
        case let action as LoadedAppState:
            return action.state
        
        case let action as ServerStarted:
            state.webServerAddress = action.webServerAddress
            state.webServerIPAddress = action.webServerIPAddress
        
        default:
            break
    }
    
    return state
}
