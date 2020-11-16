import UIKit
import MobileVLCKit
import RxCocoa
import RxSwift
import DifferenceKit

class VideosListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var viewModel: VideosListViewModel!
    private var videos = [VideoViewEntity]()
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewModel = VideosListViewModel(vc: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Library"
        
        collectionView.collectionViewLayout = UICollectionViewLayout.idiomicCellLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        viewModel.viewDidLoad()
                
        viewModel.videos
            .map { $0.map(VideoViewEntity.init(video:)) }
            .do(onNext: nil, afterNext: makeThumbneils(for:))
            .subscribe(onNext: { [self] newVideos in
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
    
}

//To iPad and iPhone popover looks same
extension VideosListViewController: UIPopoverPresentationControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = .popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
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
            viewModel.addVideoPressed()
        } else {
            viewModel.itemSelected(indexPath: indexPath)
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
                self.viewModel.removeVideo(indexPath: indexPath, removeAllCards: false)
            }
            let removeWithCards = UIAction(
                title: "Удалить со всеми карточками",
                image: UIImage(systemName: "trash"),
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: .destructive,
                state: .off
            ) { _ in
                self.viewModel.removeVideo(indexPath: indexPath, removeAllCards: true)
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
