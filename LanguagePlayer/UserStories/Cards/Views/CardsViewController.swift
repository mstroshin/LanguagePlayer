import UIKit
import RxSwift
import RxCocoa
import DifferenceKit

class CardsViewController: UIViewController {
    var viewModel: CardsViewModel!

    @IBOutlet private weak var collectionView: UICollectionView!
    private var disposeBag = DisposeBag()
    private var cards = [CardViewEntity]()
    
    let colorNumbers = Array(1...6).shuffled()
    
    override func viewDidLoad() {
        setupViews()
        super.viewDidLoad()
        
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.output.cards
            .map { $0.map(CardViewEntity.init(translation:)) }
            .drive(onNext: { [weak self] cards in
                guard let self = self else { return }
                self.collectionView.diffUpdate(source: self.cards, target: cards) { data in
                    self.cards = data
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewLayout.idiomicCellLayout()
        
        title = NSLocalizedString("cards", comment: "")
    }
    
}

extension CardsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as? CardCollectionViewCell else {
            fatalError("Cell must be CardCollectionViewCell subclass")
        }
        let item = cards[indexPath.row]
        cell.delegate = self
        cell.configure(with: item)

        let colorNumber = self.colorNumbers[indexPath.row % 6]
        cell.set(bgColor: UIColor(named: "cardColor\(colorNumber)"), playButtonColor: UIColor(named: "playColor\(colorNumber)"))

        return cell
    }
    
}

extension CardsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else {
            return
        }
        cell.flip()
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { actions -> UIMenu? in
            let remove = UIAction(
                title: NSLocalizedString("remove", comment: ""),
                image: UIImage(systemName: "trash"),
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: .destructive,
                state: .off
            ) { [self] _ in
                //Fix fucking Apple removing animation bug
                guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else {
                    return
                }
                cell.isUserInteractionEnabled = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                    viewModel.input.removeCard.onNext(indexPath.row)
                }
                //
            }
            
            return UIMenu(
                title: NSLocalizedString("choose", comment: ""),
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
        viewModel.input.playVideo.onNext(indexPath.row)
    }

}
