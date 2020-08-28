import UIKit

protocol CardCollectionViewCellDelegate: class {
    func didPressPlayButton(in cell: CardCollectionViewCell)
}

class CardCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: CardCollectionViewCell.self)

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var videoTitleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    
    weak var delegate: CardCollectionViewCellDelegate?
    
    override func updateConstraints() {
        self.textLabel.preferredMaxLayoutWidth = self.textLabel.bounds.width
        super.updateConstraints()
    }
    
    func configure(with data: CardItemState) {
        self.textLabel.text = data.source
        self.videoTitleLabel.text = data.videoTitle
        self.playButton.isHidden = data.videoId == nil
    }
    
    func set(bgColor: UIColor?, playButtonColor: UIColor?) {
        self.contentView.backgroundColor = bgColor
        self.playButton.tintColor = playButtonColor
        
        self.contentView.layer.shadowColor = bgColor?.cgColor
        self.contentView.layer.shadowOpacity = 1
        self.contentView.layer.shadowOffset = CGSize.zero
        self.contentView.layer.shadowRadius = 5
    }
    
    func flip(with text: String) {
        UIView.transition(
            with: self.contentView,
            duration: 0.3,
            options: .transitionFlipFromLeft,
            animations: { () -> Void in
                self.textLabel.text = text
            },
            completion: nil
        )
    }
    
    @IBAction func didPressPlayButton(_ sender: UIButton) {
        self.delegate?.didPressPlayButton(in: self)
    }
}
