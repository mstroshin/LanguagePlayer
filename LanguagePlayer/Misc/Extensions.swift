import Foundation
import UIKit
import DifferenceKit
import StoreKit

extension UIViewController {
    static func createFromMainStoryboard<T>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
}

extension UITableView {
    func diffUpdate<D: Differentiable>(source: [D], target: [D], setData: ([D]) -> Void) {
        let changeset = StagedChangeset(source: source, target: target)
        reload(using: changeset, with: .fade, setData: setData)
    }
}

extension UICollectionView {
    func diffUpdate<D: Differentiable>(source: [D], target: [D], setData: ([D]) -> Void) {
        let changeset = StagedChangeset(source: source, target: target)
        reload(using: changeset, setData: setData)
    }
}

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
}

extension SKProduct {

    var localizedPrice: String? {
        return priceFormatter(locale: priceLocale).string(from: price)
    }
    
    private func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
    
    @available(iOSApplicationExtension 11.2, iOS 11.2, OSX 10.13.2, tvOS 11.2, watchOS 6.2, macCatalyst 13.0, *)
    var localizedSubscriptionPeriod: String {
        guard let subscriptionPeriod = self.subscriptionPeriod else { return "" }
        
        let dateComponents: DateComponents
        
        switch subscriptionPeriod.unit {
        case .day: dateComponents = DateComponents(day: subscriptionPeriod.numberOfUnits)
        case .week: dateComponents = DateComponents(weekOfMonth: subscriptionPeriod.numberOfUnits)
        case .month: dateComponents = DateComponents(month: subscriptionPeriod.numberOfUnits)
        case .year: dateComponents = DateComponents(year: subscriptionPeriod.numberOfUnits)
        @unknown default:
            print("WARNING: SwiftyStoreKit localizedSubscriptionPeriod does not handle all SKProduct.PeriodUnit cases.")
            // Default to month units in the unlikely event a different unit type is added to a future OS version
            dateComponents = DateComponents(month: subscriptionPeriod.numberOfUnits)
        }

        return DateComponentsFormatter.localizedString(from: dateComponents, unitsStyle: .short) ?? ""
    }
    
}

precedencegroup AssignmentPrecedence {}
infix operator ?=
func ?= <T: Any> (left: inout T, right: T?) {
    if let right = right {
        left = right
    }
}
