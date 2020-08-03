import Foundation

struct AppStateActions {
    
    struct LoadAppState: Action {}
    
    struct LoadedAppState: Action {
        let state: AppState
    }
    
    struct SaveAppState: Action {}
    
    struct SaveVideo: Action {
        let data: Data
    }
    
}
