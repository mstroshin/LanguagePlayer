import UIKit
import MobileVLCKit
import ReSwift

class VideosListViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var videosList: [VideoViewState] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.router = VideosListRouter(self, screen: .videos)
        self.title = "Video Library"
        
        self.collectionView.collectionViewLayout = self.createLayout()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: {
            $0.select(VideoListViewState.init)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(180),
            heightDimension: .absolute(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: .flexible(0),
            top: nil,
            trailing: .flexible(16), bottom: nil
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
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

extension VideosListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.videosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoCollectionViewItem.identifier,
            for: indexPath
        ) as! VideoCollectionViewItem
        cell.titleLabel.text = self.videosList[indexPath.row].videoTitle
        cell.contentView.layer.cornerRadius = 12
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = self.videosList[indexPath.row]
        
        store.dispatch(NavigationActions.Navigate(
            screen: .player,
            transitionType: .present(.fullScreen),
            data: ["videoId": video.id]
        ))
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { actions -> UIMenu? in
            let remove = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { _ in
                let video = self.videosList[indexPath.row]
                store.dispatch(AppStateActions.RemoveVideo(id: video.id))
            }
            return UIMenu(title: "Выберите действие:", image: nil, identifier: nil, options: .destructive, children: [remove])
        }
        
        return configuration
    }
    
}

extension VideosListViewController: VLCMediaThumbnailerDelegate {
    
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        print("mediaThumbnailerDidTimeOut")
    }
    
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        if let label = mediaThumbnailer.accessibilityLabel, let row = Int(label),
            let cell = self.collectionView.cellForItem(at: IndexPath(item: row, section: 0)) as? VideoCollectionViewItem {
            cell.image.image = UIImage(cgImage: thumbnail)
        }
    }
    
}

extension VideosListViewController: StoreSubscriber {
    typealias State = VideoListViewState
    
    func newState(state: VideoListViewState) {
        DispatchQueue.main.async {
            self.collectionView.diffUpdate(source: self.videosList, target: state.videos) {
                self.videosList = $0
                self.makeThumbneils(for: $0)
            }
        }
    }
    
    private func makeThumbneils(for videos: [VideoViewState]) {
        for (index, video) in videos.enumerated() {
            let media = VLCMedia(url: video.videoUrl)
            let thumbnailer = VLCMediaThumbnailer(media: media, andDelegate: self)
            thumbnailer?.accessibilityLabel = "\(index)"
            thumbnailer?.fetchThumbnail()
        }
    }
    
}
