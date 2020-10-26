import UIKit
import ReSwift

class CardsViewController: BaseViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var items = [CardItemState]()
    var cardsSides = [Bool]()
    let colorNumbers = Array(1...6).shuffled()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.router = CardsRouter(self, screen: .cards)
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: { $0.select(CardsViewState.init).skipRepeats() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    private func setupViews() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = UICollectionViewLayout.idiomicCellLayout()
    }
    
}

extension CardsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as? CardCollectionViewCell else {
            fatalError("Cell must be CardCollectionViewCell subclass")
        }
        let item = self.items[indexPath.row]
        cell.delegate = self
        cell.configure(with: item)
        
        let colorNumber = self.colorNumbers[indexPath.row % 6]
        cell.set(bgColor: UIColor(named: "cardColor\(colorNumber)"), playButtonColor: UIColor(named: "playColor\(colorNumber)"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else {
            return
        }
        let item = self.items[indexPath.row]
        let isBackSide = self.cardsSides[indexPath.row]
        cell.flip(with: isBackSide ? item.source : item.target)
        
        self.cardsSides[indexPath.row] = !isBackSide
    }
    
func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    let configuration = UIContextMenuConfiguration(
        identifier: nil,
        previewProvider: nil
    ) { actions -> UIMenu? in
        let remove = UIAction(
            title: "Удалить",
            image: UIImage(systemName: "trash"),
            identifier: nil,
            discoverabilityTitle: nil,
            attributes: .destructive,
            state: .off
        ) { _ in
            let item = self.items[indexPath.row]
            store.dispatch(RemoveTranslation(id: item.id))
            store.dispatch(SaveAppState());
        }
        
        return UIMenu(
            title: "Выберите действие:",
            image: nil,
            identifier: nil,
            options: .destructive,
            children: [remove]
        )
    }
    
    return configuration
}
    
}

extension CardsViewController: CardCollectionViewCellDelegate {
    
    func didPressPlayButton(in cell: CardCollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        let item = self.items[indexPath.row]
        
        store.dispatch(NavigationActions.Navigate(
            screen: .player,
            transitionType: .present(.fullScreen),
            data: ["videoId": item.videoId!,
                   "from": item.fromTime,
                   "to": item.toTime]
        ))
    }
    
}

extension CardsViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = CardsViewState
    
    func newState(state: CardsViewState) {
        self.collectionView.diffUpdate(source: self.items, target: state.cards) {
            self.items = $0
            self.cardsSides = Array(repeating: false, count: $0.count)
        }
    }
}
