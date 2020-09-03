import Foundation

struct UploadTutorialViewState: Equatable {
    let webServerIPAddress: String?
    let webServerAddress: String?
    
    init(appState: AppState) {
        self.webServerIPAddress = appState.webServerIPAddress
        self.webServerAddress = appState.webServerAddress
    }
}
