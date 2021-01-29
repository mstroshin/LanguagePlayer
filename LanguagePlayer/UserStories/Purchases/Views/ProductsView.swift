import Foundation
import UIKit
import RxCocoa
import RxSwift
import Purchases

class ProductsView: UIView {
    @IBOutlet private weak var benefitsLabel: UILabel!
    @IBOutlet private weak var productsStackView: UIStackView!
    @IBOutlet private weak var restoreButton: UIButton!
    //    @IBOutlet private weak var termsAndPrivacyLabel: UILabel!
    private var disposeBag = DisposeBag()
    
    var restoreButtonAction: ControlEvent<Void> {
        restoreButton.rx.tap
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        localize()
    }
    
    private func localize() {
        benefitsLabel.text = NSLocalizedString("withoutLimit", comment: "") + "\n"
            + NSLocalizedString("supportDeveloper", comment: "")
        
        if UIDevice.iphone {
            benefitsLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        } else {
            benefitsLabel.font = .systemFont(ofSize: 32, weight: .semibold)
        }
        
        restoreButton.setTitle(NSLocalizedString("restorePurchase", comment: ""), for: .normal)
        restoreButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        restoreButton.setTitleColor(UIColor(named: "purchaseButtonColor"), for: .normal)
    }
    
    func makeButtons(for packages: [Purchases.Package], bindTo buy: AnyObserver<Purchases.Package>) {
        disposeBag = DisposeBag()
        productsStackView.subviews.forEach { $0.removeFromSuperview() }
        
        for package in packages {
            let button = UIButton()
            button.addConstraint(button.heightAnchor.constraint(equalToConstant: 64))
            button.cornerRadius = 32
            button.backgroundColor = UIColor(named: "purchaseButtonColor")
            button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
            
            switch package.packageType {
            case .monthly:
                button.setTitle("\(package.localizedPriceString) / " + NSLocalizedString("month", comment: ""), for: .normal)
            case .annual:
                button.titleLabel?.lineBreakMode = .byWordWrapping
                button.titleLabel?.textAlignment = .center
                
                let title = annualButtonTitle(annualPackage: package, monthPackage: packages.first(where: { $0.packageType == .monthly }))
                button.setAttributedTitle(title, for: .normal)
            case .lifetime:
                button.setTitle("\(package.localizedPriceString) / " + NSLocalizedString("lifetime", comment: ""), for: .normal)
            default:
                button.setTitle(package.localizedPriceString, for: .normal)
            }
            
            button.rx.tap.bind { _ in
                buy.onNext(package)
            }.disposed(by: disposeBag)
            
            productsStackView.addArrangedSubview(button)
        }
    }
    
    private func annualButtonTitle(annualPackage: Purchases.Package, monthPackage: Purchases.Package?) -> NSAttributedString {
        let price = "\(annualPackage.localizedPriceString) / " + NSLocalizedString("year", comment: "")
        
        var benefits = ""
        if annualPackage.product.introductoryPrice != nil {
            benefits += String.localizedStringWithFormat(NSLocalizedString("trial", comment: ""), 7)
        }
        
        if let monthPrice = monthPackage?.product.price {
            let savePercent = Int(ceil(monthPrice.dividing(by: annualPackage.product.price.dividing(by: 12)).multiplying(by: 100).subtracting(100).floatValue))
            benefits += " " + NSLocalizedString("and", comment: "") + " " + String.localizedStringWithFormat(NSLocalizedString("savePercent", comment: ""), savePercent)
        }
                
        let attributedString = NSMutableAttributedString(string: price + "\n" + benefits)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.string.count))
        
        let priceRange = NSRange(attributedString.string.range(of: price)!, in: attributedString.string)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24, weight: .semibold), range: priceRange)
        
        let benefitsRange = NSRange(attributedString.string.range(of: benefits)!, in: attributedString.string)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .semibold), range: benefitsRange)
        
        return attributedString
    }
    
}
