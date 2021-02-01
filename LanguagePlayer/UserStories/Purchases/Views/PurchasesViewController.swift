import UIKit
import Toast_Swift
import RxSwift
import RxCocoa
import Purchases

class PurchasesViewController: UIViewController {
    var viewModel: PurchasesViewModel!
    
    @IBOutlet private weak var productsView: ProductsView!
    @IBOutlet private weak var alreadyHasPremiumView: UIView!
    @IBOutlet private weak var alreadyHasPremiumLabel: UILabel!
    @IBOutlet private weak var alreadyHasPremiumButton: UIButton!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noConnectionErrorView: NoConnectionErrorView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction))
        
        hideAllViews()
        localizeLabelsAndButtons()
        bind(viewModel: viewModel)
        
        viewModel.input.retrieveProducts.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.iphone {
            InterfaceOrientation.lock(orientation: .portrait, rotation: .portrait)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.iphone {
            InterfaceOrientation.lock(orientation: .portrait, rotation: .portrait)
        }
    }
    
    private func localizeLabelsAndButtons() {
        title = "Premium"
        
        alreadyHasPremiumLabel.text = NSLocalizedString("alreadyHasPremium", comment: "")
        alreadyHasPremiumButton.setTitle(NSLocalizedString("yippee", comment: ""), for: .normal)
        
        noConnectionErrorView.localize(
            title: NSLocalizedString("noConnectionErrorTitle", comment: ""),
            buttonTitle: NSLocalizedString("retry", comment: "")
        )
    }
    
    private func bind(viewModel: PurchasesViewModel) {
        alreadyHasPremiumButton.rx.tap
            .bind(to: viewModel.input.close)
            .disposed(by: disposeBag)
        
        productsView.restoreButtonAction
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
                self?.productsView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        viewModel.output.products
            .drive(onNext: { [weak self] packages in
                self?.hideAllViews()
                self?.productsView.makeButtons(for: packages, bindTo: viewModel.input.buy)
                self?.productsView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        viewModel.output.buyingResult
            .drive(onNext: { [weak self] in
                self?.hideAllViews()
                self?.alreadyHasPremiumView.isHidden = false
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
                self?.hideAllViews()
                self?.alreadyHasPremiumView.isHidden = !hasPremium
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
                self?.hideAllViews()
                self?.alreadyHasPremiumView.isHidden = !hasPremium
            })
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .drive(onNext: { [weak self] purchasesError in
                self?.hideAllViews()

                switch purchasesError {
                case .noInternet:
                    self?.noConnectionErrorView.isHidden = false
                case .cancel:
                    self?.productsView.isHidden = false
                    self?.view.makeToast(
                        "Purchase canceled by user",
                        duration: 3,
                        position: .bottom,
                        title: "Error"
                    )
                case .other:
                    self?.productsView.isHidden = false
                    self?.view.makeToast(
                        "Some error occured",
                        duration: 3,
                        position: .bottom,
                        title: "Error"
                    )
                }
            })
            .disposed(by: disposeBag)
        
        noConnectionErrorView.buttonAction = { [weak self] in
            self?.viewModel.input.retrieveProducts.onNext(())
        }
    }
    
    private func hideAllViews() {
        noConnectionErrorView.isHidden = true
        alreadyHasPremiumView.isHidden = true
        productsView.isHidden = true
        loadingIndicator.isHidden = true
    }
    
    @objc private func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
