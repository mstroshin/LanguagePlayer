import UIKit

protocol DoubleSubtitlesViewDelegate: class {
    func didPressAddToFavorite()
}

class DoubleSubtitlesView: UIView {
    weak var delegate: DoubleSubtitlesViewDelegate?
    
    @IBOutlet private weak var sourceSubtitleLabel: UILabel!
    @IBOutlet private weak var targetSubtitleLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.iphone {
            sourceSubtitleLabel.font = .systemFont(ofSize: 24, weight: .regular)
            targetSubtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    func set(subtitles: DoubleSubtitles) {
        sourceSubtitleLabel.text = subtitles.source?.text
        targetSubtitleLabel.text = subtitles.target?.text
        
        favoriteButton.setImage(UIImage(systemName: subtitles.addedToFavorite ? "book.fill" : "book"), for: .normal)
        favoriteButton.isHidden = subtitles.source == nil && subtitles.target == nil
        
    }
    
    @IBAction private func didPressAddToFavoriteButton(_ sender: UIButton) {
        delegate?.didPressAddToFavorite()
    }
}
