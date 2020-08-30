import Foundation
import ReSwift

protocol AppStateActions: Action {}

//MARK: - App State
struct LoadAppState: AppStateActions {}

struct LoadedAppState: AppStateActions {
    let state: AppState
}

struct SaveAppState: AppStateActions {}
    
//MARK: - Server
struct ServerStarted: AppStateActions {
    var webServerIPAddress: String?
    var webServerAddress: String?
}
