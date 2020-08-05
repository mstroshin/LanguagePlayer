import Foundation
import UIKit
import AVFoundation
import ReSwift

class VideosListViewController: UICollectionViewController {
    var videosList: [VideoViewState] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video Library"
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
