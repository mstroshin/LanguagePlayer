import UIKit
import Toast_Swift
import RxSwift
import RxCocoa
import Purchases

class PurchasesViewController: UIViewController {
    var viewModel: PurchasesViewModel!
    
    @IBOutlet private weak var benefitsLabel: UILabel!
    @IBOutlet private weak var productsStackView: UIStackView!
    @IBOutlet private weak var restoreButton: UIButton!
//    @IBOutlet private weak var termsAndPrivacyLabel: UILabel!
    @IBOutlet private weak var alreadyHasPremiumView: UIView!
    @IBOutlet private weak var alreadyHasPremiumLabel: UILabel!
    @IBOutlet private weak var alreadyHasPremiumButton: UIButton!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction))
        
        localizeLabelsAndButtons()
        bind(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        InterfaceOrientation.lock(orientation: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        InterfaceOrientation.lock(orientation: .all)
    }
    
    private func localizeLabelsAndButtons() {
        title = "Premium"
        
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
        
        alreadyHasPremiumLabel.text = NSLocalizedString("alreadyHasPremium", comment: "")
        alreadyHasPremiumButton.setTitle(NSLocalizedString("yippee", comment: ""), for: .normal)
    }
    
    private func bind(viewModel: PurchasesViewModel) {
        alreadyHasPremiumButton.rx.tap
            .bind(to: viewModel.input.close)
            .disposed(by: disposeBag)
        
        restoreButton.rx.tap
            .bind(to: viewModel.input.restore)
            .disposed(by: disposeBag)
        
        viewModel.output.activityIndicator
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        viewModel.output.activityIndicator
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.output.activityIndicator
            .filter { $0 == true }
            .drive(onNext: { [weak self] _ in
                self?.alreadyHasPremiumView.isHidden = true
                self?.benefitsLabel.isHidden = true
                self?.productsStackView.isHidden = true
                self?.restoreButton.isHidden = true
            })
            .disposed(by: disposeBag)
        
        viewModel.output.products
            .drive(onNext: { [weak self] result in
                switch result {
                case .success(let packages):
                    self?.makeButtons(for: packages, bindTo: viewModel)
                case .failure(let error):
                    self?.view.makeToast(
                        error.localizedDescription,
                        duration: 3,
                        position: .bottom,
                        title: "Some error"
                    )
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.buyingResult
            .drive(onNext: { [weak self] in
                self?.showAlreadyHasPremuim(true)
                self?.view.makeToast(
                    "Success",
                    duration: 3,
                    position: .bottom,
                    title: "Success"
                )
            })
            .disposed(by: disposeBag)
        
        viewModel.output.restoringResult
            .drive(onNext: { [weak self] hasPremium in
                self?.showAlreadyHasPremuim(hasPremium)
                if hasPremium {
                    self?.view.makeToast(
                        "Success",
                        duration: 3,
                        position: .bottom,
                        title: "Success"
                    )
                } else {
                    self?.view.makeToast(
                        "You have no premium",
                        duration: 3,
                        position: .bottom,
                        title: "Error"
                    )
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.hasPremium
            .drive(onNext: { [weak self] hasPremium in
                self?.showAlreadyHasPremuim(hasPremium)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .drive(onNext: { [weak self] errorText in
                self?.showAlreadyHasPremuim(false)
                self?.view.makeToast(
                    errorText,
                    duration: 3,
                    position: .bottom,
                    title: "Error"
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlreadyHasPremuim(_ shown: Bool) {
        self.alreadyHasPremiumView.isHidden = !shown
        self.benefitsLabel.isHidden = shown
        self.productsStackView.isHidden = shown
        self.restoreButton.isHidden = shown
    }
    
    private func makeButtons(for packages: [Purchases.Package], bindTo viewModel: PurchasesViewModel) {
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
                viewModel.input.buy.onNext(package)
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
    
    @objc private func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
