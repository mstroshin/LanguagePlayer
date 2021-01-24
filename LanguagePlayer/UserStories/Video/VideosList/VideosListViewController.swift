import UIKit
import RxCocoa
import RxSwift

class VideosListViewController: UIViewController {
    var viewModel: VideosListViewModel!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var videos = [VideoItemViewModel]()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Library"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "purchased.circle.fill"),
            landscapeImagePhone: nil,
            style: .plain,
            target: self,
            action: #selector(premiumButtonPressed)
        )
        
        collectionView.collectionViewLayout = UICollectionViewLayout.idiomicCellLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        bind()
        
        viewModel.output.videos
            .drive(onNext: { [self] newVideos in
                collectionView.diffUpdate(source: videos, target: newVideos) { data in
                    videos = data
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bind() {
        
    }
    
    @objc private func premiumButtonPressed() {
        viewModel.input.openPremium.onNext(())
    }
    
}

extension VideosListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //+1 cuz adding cell
        videos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == videos.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddingVideoCollectionViewCell", for: indexPath)
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewItem.identifier, for: indexPath) as? VideoCollectionViewItem else {
            fatalError("Cell must be VideoCollectionViewItem")
        }
        cell.bind(viewModel: videos[indexPath.row])
        
        return cell
    }
    
}

extension VideosListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == videos.count {
            viewModel.input.openUploadTutorial.onNext(())
        } else {
            viewModel.input.openVideo.onNext(indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == videos.count {
            return nil
        }
        
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
                self.viewModel.input.removeVideo.onNext(indexPath.row)
            }
            let removeWithCards = UIAction(
                title: "Удалить со всеми карточками",
                image: UIImage(systemName: "trash"),
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: .destructive,
                state: .off
            ) { _ in
                self.viewModel.input.removeVideoWithCards.onNext(indexPath.row)
            }

            return UIMenu(
                title: "Выберите действие:",
                image: nil,
                identifier: nil,
                options: .destructive,
                children: [remove, removeWithCards]
            )
        }

        return configuration
    }

}
