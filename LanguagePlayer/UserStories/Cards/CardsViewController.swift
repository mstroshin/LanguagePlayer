import UIKit
import ReSwift

class CardsViewController: BaseViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    var items = [CardItemState]()
    var cardsSides = [Bool]()
    
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
        self.collectionView.collectionViewLayout = self.createLayout()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(480),
            heightDimension: .absolute(280)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: .fixed(8),
            top: .fixed(8),
            trailing: .fixed(8),
            bottom: .fixed(8)
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: .fixed(8),
            top: .fixed(8),
            trailing: .fixed(8),
            bottom: .fixed(8)
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    
}

extension CardsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
