import UIKit

protocol DoubleSubtitlesViewDelegate: class {
    func didPressAddToFavorite()
}

class DoubleSubtitlesView: UIView {
    weak var delegate: DoubleSubtitlesViewDelegate?
    
    @IBOutlet private weak var sourceSubtitleLabel: UILabel!
    @IBOutlet private weak var targetSubtitleLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    func set(subtitles: DoubleSubtitles) {
        self.sourceSubtitleLabel.text = subtitles.source?.text
        self.targetSubtitleLabel.text = subtitles.target?.text
        self.favoriteButton.setImage(UIImage(systemName: subtitles.addedToFavorite ? "book.fill" : "book"), for: .normal)
    }
    
    @IBAction private func didPressAddToFavoriteButton(_ sender: UIButton) {
        delegate?.didPressAddToFavorite()
    }
}
