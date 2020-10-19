import Foundation
import UIKit
import ReSwift

class UploadTutorialViewController: UIViewController {
    @IBOutlet private var ipAddressLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var tutorialLabel: UILabel!
    @IBOutlet private var orLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) {
            $0.select(UploadTutorialViewState.init).skipRepeats()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
}

extension UploadTutorialViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = UploadTutorialViewState
    
    func newState(state: UploadTutorialViewState) {
        DispatchQueue.main.async {
            self.ipAddressLabel.text = state.webServerIPAddress
            
            if let ipAddress = state.webServerBonjourAddress {
                self.orLabel.isHidden = false
                self.addressLabel.isHidden = false
                self.addressLabel.text = ipAddress
            } else {
                self.orLabel.isHidden = true
                self.addressLabel.isHidden = true
            }
        }
    }
}
