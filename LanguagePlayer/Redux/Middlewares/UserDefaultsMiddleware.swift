import ReSwift

func userDefaultsMiddleware(userDefaults: UserDefaultsDataStore) -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case _ as LoadAppState:
                    if let loadedState = userDefaults.loadAppState() {
                        next(LoadedAppState(state: loadedState))
                    }
                case _ as SaveAppState:
                    guard let state = getState() else { return }
                    userDefaults.save(appState: state)
                default:
                    next(action)
                }
            }
        }
    }
}
