import Foundation
import UIKit
import AVFoundation
import ReSwift

class VideosListViewController: UICollectionViewController {
    var router: VideosListRouter!
    var videosList: [VideoViewState] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.router = VideosListRouter(self)
        self.title = "Video Library"
        
        self.collectionView.collectionViewLayout = self.createLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: {
            $0.select(VideoListViewState.init)
        })
        self.router.subscribe()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
        self.router.unsubscribe()
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

extension VideosListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.videosList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoCollectionViewItem.identifier,
            for: indexPath
        ) as! VideoCollectionViewItem
        cell.image.image = self.videosList[indexPath.row].videoPreviewImage
        cell.titleLabel.text = self.videosList[indexPath.row].videoTitle
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = self.videosList[indexPath.row]
        
        store.dispatch(NavigationActions.Navigate(
            screen: .player,
            transitionType: .present(.fullScreen),
            data: ["videoId": video.id]
        ))
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
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

extension VideosListViewController: StoreSubscriber {
    typealias State = VideoListViewState
    
    func newState(state: VideoListViewState) {
        DispatchQueue.main.async {
            self.collectionView.diffUpdate(source: self.videosList, target: state.videos) {
                self.videosList = $0
            }
        }
    }
    
}
