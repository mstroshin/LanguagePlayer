import Foundation
import UIKit

class NoConnectionErrorView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    var buttonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func localize(title: String, buttonTitle: String) {
        titleLabel.text = title
        button.setTitle(buttonTitle, for: .normal)
    }
    
    @IBAction private func buttonAction(sender: UIButton) {
        buttonAction?()
    }
}
