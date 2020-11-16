import UIKit
import Toast_Swift

class PurchasesViewController: UIViewController {
    @IBOutlet private weak var productsStackView: UIStackView!
//    var products = [StoreProduct]()
    
//    private func makeButton(index: Int, product: StoreProduct) -> UIButton {
//        let button = UIButton()
//        button.addConstraint(button.heightAnchor.constraint(equalToConstant: 80))
//        button.cornerRadius = 12
//        button.backgroundColor = UIColor(named: "purchaseButtonColor")
//        button.addTarget(self, action: #selector(didPressPurchaseButton(_:)), for: .touchUpInside)
//        button.tag = index
//        
//        var title = ""
//        switch product.id {
//            case PurchaseIds.monthly:
//                title = "\(product.localizedPrice) / Month"
//            case PurchaseIds.year:
//                title = "\(product.localizedPrice) / Year"
//            case PurchaseIds.lifetime:
//                title = "\(product.localizedPrice) / Lifetime"
//            default:
//                title = product.localizedPrice
//        }
//        button.setTitle(title, for: .normal)
//        
//        return button
//    }
//    
//    @objc func didPressPurchaseButton(_ sender: UIButton) {
//        if sender.tag < self.products.count {
//            let productId = self.products[sender.tag].id
//            store.dispatch(Purchase(id: productId))
//        }
//    }
    
}
