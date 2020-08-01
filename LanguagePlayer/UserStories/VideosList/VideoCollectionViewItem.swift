import Foundation
import UIKit

class VideoCollectionViewItem: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let identifier = String(describing: VideoCollectionViewItem.self)
}
