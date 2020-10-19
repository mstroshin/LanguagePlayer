import Foundation

struct UploadTutorialViewState: Equatable {
    let webServerIPAddress: String?
    let webServerBonjourAddress: String?
    
    init(appState: AppState) {
        self.webServerIPAddress = appState.webServerIPAddress
        self.webServerBonjourAddress = appState.webServerAddress
    }
}
