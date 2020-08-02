struct AppEnvironment {
    let store: Store<AppState>
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = AppState()
        let middlewares: [Middleware] = []
        
        let store = Store(reducer: appStateReducer, middleware: middlewares, state: appState)
                
        return AppEnvironment(store: store)
    }
}

