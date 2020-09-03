import UIKit
import ReSwift

class PurchasesViewController: UIViewController {
    @IBOutlet private weak var productsStackView: UIStackView!
    var products = [StoreProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.dispatch(RetrieveProductsInfo())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: { $0.select(PurchasesViewState.init) })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func updateViews(with products: [StoreProduct]) {
        self.products = products
        
        //Remove all buttons
        for button in self.productsStackView.arrangedSubviews {
            self.productsStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        for button in products.enumerated().map(makeButton) {
            self.productsStackView.addArrangedSubview(button)
        }
    }
    
    private func makeButton(index: Int, product: StoreProduct) -> UIButton {
        let button = UIButton()
        button.addConstraint(button.heightAnchor.constraint(equalToConstant: 80))
        button.cornerRadius = 12
        button.backgroundColor = UIColor(named: "purchaseButtonColor")
        button.addTarget(self, action: #selector(didPressPurchaseButton(_:)), for: .touchUpInside)
        button.tag = index
        
        var title = ""
        switch product.id {
            case PurchaseIds.monthly:
                title = "\(product.localizedPrice) / Month"
            case PurchaseIds.year:
                title = "\(product.localizedPrice) / Year"
            case PurchaseIds.lifetime:
                title = "\(product.localizedPrice) / Lifetime"
            default:
                title = product.localizedPrice
        }
        button.setTitle(title, for: .normal)
        
        return button
    }
    
    @objc func didPressPurchaseButton(_ sender: UIButton) {
        if sender.tag < self.products.count {
            let productId = self.products[sender.tag].id
            store.dispatch(Purchase(id: productId))
        }
    }
    
}

extension PurchasesViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = PurchasesViewState
    
    func newState(state: PurchasesViewState) {
        DispatchQueue.main.async {
            self.updateViews(with: state.products)
        }
    }
    
}
