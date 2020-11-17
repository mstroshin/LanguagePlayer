import UIKit
import RxSwift

class SettingsCoordinator: BaseCoordinator<Void> {
    private let settingsViewController: UIViewController
    
    init(settingsViewController: UIViewController) {
        self.settingsViewController = settingsViewController
    }
    
    override func start() -> Observable<Void> {
        return .never()
    }
}
