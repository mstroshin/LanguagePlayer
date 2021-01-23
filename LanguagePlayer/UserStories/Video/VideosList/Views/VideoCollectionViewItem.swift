import Foundation
import UIKit

class VideoCollectionViewItem: UICollectionViewCell {
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    static let identifier = String(describing: VideoCollectionViewItem.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
    }
    
    func bind(viewModel: VideoItemViewModel) {
        image.image = UIImage(contentsOfFile: viewModel.thumbnailImagePath)
        titleLabel.text = viewModel.title
    }
}
