import Foundation
import ReSwift

enum Screen: String, Codable {
    case videos
    case dictionary
    case settings
    case player
    
    var isTab: Bool {
        [.videos, .dictionary, .settings].contains(self)
    }
}

enum TransitionType {
    case present(UIModalPresentationStyle)
    case show
}

public struct NavigationState: Equatable {
    var transitionType: TransitionType?
    var transiotionData: [AnyHashable: Any]?
    var newScreen: Screen?
    
    public static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        lhs.newScreen == rhs.newScreen
    }
}

func navigationStateReducer(action: Action, state: NavigationState?) -> NavigationState {
    var state = state ?? NavigationState()
    
    switch action {
    case let action as NavigationActions.Navigate:
        state.transiotionData = action.data
        state.transitionType = action.transitionType
        state.newScreen = action.screen
    case _ as NavigationActions.NavigationCompleted:
        state.transiotionData = nil
        state.transitionType = nil
        state.newScreen = nil
    default:
        break
    }
    
    return state
}
