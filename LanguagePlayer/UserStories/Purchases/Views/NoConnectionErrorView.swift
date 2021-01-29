import Foundation
import UIKit

class NoConnectionErrorView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    var buttonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        localize()
    }
    
    private func localize() {
        titleLabel.text = NSLocalizedString("noConnectionErrorTitle", comment: "")
        button.setTitle(NSLocalizedString("retry", comment: ""), for: .normal)
    }
    
    @IBAction private func buttonAction(sender: UIButton) {
        buttonAction?()
    }
}
