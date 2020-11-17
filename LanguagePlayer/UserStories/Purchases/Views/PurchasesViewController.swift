import UIKit
import Toast_Swift
import RxSwift
import RxCocoa
import Purchases

class PurchasesViewController: UIViewController {
    @IBOutlet private weak var productsStackView: UIStackView!
    private let viewModel = PurchasesViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(viewModel: viewModel)
    }
    
    private func bind(viewModel: PurchasesViewModel) {
        viewModel.output.activityIndicator
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
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
            .drive(onNext: { [weak self] result in
                switch result {
                case .success():
                    self?.view.makeToast(
                        "Success",
                        duration: 3,
                        position: .bottom,
                        title: "Success"
                    )
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
    }
    
    private func makeButtons(for packages: [Purchases.Package], bindTo viewModel: PurchasesViewModel) {
        for package in packages {
            let button = UIButton()
            button.addConstraint(button.heightAnchor.constraint(equalToConstant: 80))
            button.cornerRadius = 12
            button.backgroundColor = UIColor(named: "purchaseButtonColor")
            
            var title = ""
            switch package.packageType {
            case .monthly:
                title = "\(package.localizedPriceString) / Month"
            case .annual:
                title = "\(package.localizedPriceString) / Year"
            case .lifetime:
                title = "\(package.localizedPriceString) / Lifetime"
            default:
                title = package.localizedPriceString
            }
            button.setTitle(title, for: .normal)
            
            button.rx.tap.bind { _ in
                viewModel.input.buy.onNext(package)
            }.disposed(by: disposeBag)
            
            productsStackView.addArrangedSubview(button)
        }
    }
    
}
