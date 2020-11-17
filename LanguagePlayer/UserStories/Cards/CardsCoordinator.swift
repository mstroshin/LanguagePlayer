import UIKit
import RxSwift

class CardsCoordinator: BaseCoordinator<Void> {
    private let cardsViewController: UIViewController
    
    init(cardsViewController: UIViewController) {
        self.cardsViewController = cardsViewController
    }
    
    override func start() -> Observable<Void> {
        return .never()
    }
}
