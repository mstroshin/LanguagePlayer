import Foundation
import ReSwift

typealias ID = Int

let store = Store(reducer: AppState.reducer, state: AppState())

struct AppState: StateType, Equatable {
    let videos = VideosListState()
    
    static func reducer(action: Action, state: AppState?) -> AppState {
        let state = state ?? AppState()
        
        return state
    }
}

struct VideosListState: Equatable {
    let videos = [VideoState]()
}
