import Foundation

class UserDefaultsDataStore {
    private let appStateKey = "AppStateStoreKey"
    
    func loadAppState() -> AppState? {
        let userDefaults = UserDefaults.standard
        
        guard let data = userDefaults.data(forKey: self.appStateKey),
            let appState = try? JSONDecoder().decode(AppState.self, from: data) else {
                return nil
        }
        
        return appState
    }
    
    func save(appState: AppState) {
        let userDefaults = UserDefaults.standard
        
        do {
            let data = try JSONEncoder().encode(appState)
            userDefaults.set(data, forKey: self.appStateKey)
            userDefaults.synchronize()
        } catch {
            print(error)
        }
    }
}
