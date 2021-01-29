import UIKit
import MobileVLCKit
import RxCocoa
import RxSwift
import DifferenceKit

class VideosListViewController: UIViewController {
    var viewModel: VideosListViewModel!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var videos = [VideoViewEntity]()
    private var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        InterfaceOrientation.lock(orientation: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        InterfaceOrientation.lock(orientation: .all)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("videoLibrary", comment: "")
        
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
        
        viewModel.output.videos
            .do(afterNext: makeThumbneils(for:))
            .drive(onNext: { [self] newVideos in
                collectionView.diffUpdate(source: videos, target: newVideos) { data in
                    videos = data
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func makeThumbneils(for videos: [VideoViewEntity]) {
        for (index, video) in videos.enumerated() {
            let media = VLCMedia(url: video.videoUrl)
            let thumbnailer = VLCMediaThumbnailer(media: media, andDelegate: self)
            thumbnailer?.accessibilityLabel = "\(index)"
            thumbnailer?.fetchThumbnail()
        }
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
        cell.titleLabel.text = videos[indexPath.row].fileName
        
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
                title: NSLocalizedString("remove", comment: ""),
                image: UIImage(systemName: "trash"),
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: .destructive,
                state: .off
            ) { _ in
                self.viewModel.input.removeVideo.onNext(indexPath.row)
            }
            let removeWithCards = UIAction(
                title: NSLocalizedString("removeWithCards", comment: ""),
                image: UIImage(systemName: "trash"),
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: .destructive,
                state: .off
            ) { _ in
                self.viewModel.input.removeVideoWithCards.onNext(indexPath.row)
            }

            return UIMenu(
                title: NSLocalizedString("choose", comment: ""),
                image: nil,
                identifier: nil,
                options: .destructive,
                children: [remove, removeWithCards]
            )
        }

        return configuration
    }

}

extension VideosListViewController: VLCMediaThumbnailerDelegate {
    
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        print("mediaThumbnailerDidTimeOut")
    }
    
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        if let label = mediaThumbnailer.accessibilityLabel, let row = Int(label), row < videos.count {
            let thumbnail = UIImage(cgImage: thumbnail)
            videos[row].thumbnail = thumbnail
            
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: row, section: 0)) as? VideoCollectionViewItem {
                cell.image.image = thumbnail
            }
        }
    }
    
}
