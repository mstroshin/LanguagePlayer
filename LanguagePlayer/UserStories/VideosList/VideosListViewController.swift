import Foundation
import UIKit

class VideosListViewController: UICollectionViewController {
    var videosList: [VideoState] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        store.unsubscribe(self)
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
        cell.image.image = nil
        cell.titleLabel.text = self.videosList[indexPath.row].title
        
        return cell
    }
    
}

//extension VideosListViewController: StoreSubscriber {
//    typealias StoreSubscriberStateType = AppState
//    
//    func newState(state: AppState) {
//        self.collectionView.diffUpdate(source: self.videosList, target: state.videos.videos) {
//            self.videosList = $0
//        }
//    }
//}
