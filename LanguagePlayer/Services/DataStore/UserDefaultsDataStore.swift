import Foundation

class UserDefaultsDataStore {
    private static let appStateKey = "AppStateStoreKey"
    
    static func loadAppState() -> AppState? {
        let userDefaults = UserDefaults.standard
        
        guard let data = userDefaults.data(forKey: UserDefaultsDataStore.appStateKey),
            let appState = try? JSONDecoder().decode(AppState.self, from: data) else {
                return nil
        }
        
        return appState
    }
    
    static func save(appState: AppState) {
        let userDefaults = UserDefaults.standard
        
        do {
            let data = try JSONEncoder().encode(appState)
            userDefaults.set(data, forKey: UserDefaultsDataStore.appStateKey)
            userDefaults.synchronize()
        } catch {
            print(error)
        }
    }
}
