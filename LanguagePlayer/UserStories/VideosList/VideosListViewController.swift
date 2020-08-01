import Foundation
import UIKit

class VideosListViewController: UICollectionViewController {
    
}

extension VideosListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoCollectionViewItem.identifier,
            for: indexPath
        ) as! VideoCollectionViewItem
        cell.image.image = nil
        cell.titleLabel.text = ""
        
        return cell
    }
    
}
