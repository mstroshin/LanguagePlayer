import Foundation
import ReSwift

enum Screen: String, Codable {
    case videos
    case dictionary
    case settings
    case player
    case cards
    
    var isTab: Bool {
        [.videos, .dictionary, .settings, .cards].contains(self)
    }
}

enum TransitionType {
    case present(UIModalPresentationStyle)
    case show
}

public struct NavigationState: Equatable {
    var isNavigating: Bool = false
    var transitionType: TransitionType?
    var transiotionData: [AnyHashable: Any]?
    var newScreen: Screen?
    
    public static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        lhs.isNavigating == rhs.isNavigating
            && lhs.newScreen == rhs.newScreen
    }
}

func navigationStateReducer(action: Action, state: NavigationState?) -> NavigationState {
    var state = state ?? NavigationState()
    
    switch action {
    case let action as NavigationActions.Navigate:
        state.isNavigating = true
        state.transiotionData = action.data
        state.transitionType = action.transitionType
        state.newScreen = action.screen
    case _ as NavigationActions.NavigationCompleted:
        state.isNavigating = false
        state.transiotionData = nil
        state.transitionType = nil
        state.newScreen = nil
    default:
        break
    }
    
    return state
}
