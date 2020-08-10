import ReSwift
import Foundation

var store: Store<AppState>!

struct AppEnvironment {
    let store: Store<AppState>
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = AppState()
        
        let filestore = filestoreMiddleware(filestore: LocalDiskStore())
        let userDefaults = userDefaultsMiddleware(userDefaults: UserDefaultsDataStore())
        
        let store = Store(
            reducer: appStateReducer,
            state: appState,
            middleware: [filestore, userDefaults],
            automaticallySkipsRepeats: true
        )
                
        return AppEnvironment(store: store)
    }
}

