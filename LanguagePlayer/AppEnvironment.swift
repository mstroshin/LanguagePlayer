import ReSwift
import ReSwift_Thunk

var store: Store<AppState>!

struct AppEnvironment {
    let store: Store<AppState>
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = AppState()
        let thunkMiddleware: Middleware<AppState> = createThunkMiddleware()
        let store = Store(reducer: appStateReducer, state: appState, middleware: [thunkMiddleware], automaticallySkipsRepeats: true)
                
        return AppEnvironment(store: store)
    }
}

