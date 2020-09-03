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
            if let address = state.webServerAddress {
                self.addressLabel.text = address
            }
            
            if let ipAddress = state.webServerIPAddress {
                self.orLabel.isHidden = false
                self.ipAddressLabel.isHidden = false
                self.ipAddressLabel.text = ipAddress
            } else {
                self.orLabel.isHidden = true
                self.ipAddressLabel.isHidden = true
            }
        }
    }
}
