import UIKit

protocol CardCollectionViewCellDelegate: class {
    func didPressPlayButton(in cell: CardCollectionViewCell)
}

class CardCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: CardCollectionViewCell.self)

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var videoTitleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    private var data: CardViewEntity?
    private var sourceShown = true
    
    weak var delegate: CardCollectionViewCellDelegate?
    
    override func updateConstraints() {
        self.textLabel.preferredMaxLayoutWidth = self.textLabel.bounds.width
        super.updateConstraints()
    }
    
    func configure(with data: CardViewEntity) {
        self.isUserInteractionEnabled = true
        self.data = data
        
        self.textLabel.text = data.source
        self.videoTitleLabel.text = data.videoTitle
        self.playButton.isHidden = data.videoTitle == nil
    }
    
    func set(bgColor: UIColor?, playButtonColor: UIColor?) {
        self.contentView.backgroundColor = bgColor
        self.playButton.tintColor = playButtonColor
        
        self.contentView.layer.shadowColor = bgColor?.cgColor
        self.contentView.layer.shadowOpacity = 1
        self.contentView.layer.shadowOffset = CGSize.zero
        self.contentView.layer.shadowRadius = 5
    }
    
    func flip() {
        sourceShown.toggle()
        
        UIView.transition(
            with: self.contentView,
            duration: 0.3,
            options: .transitionFlipFromLeft,
            animations: { [self] () -> Void in
                self.textLabel.text = sourceShown ? data?.source : data?.target
            },
            completion: nil
        )
    }
    
    @IBAction func didPressPlayButton(_ sender: UIButton) {
        self.delegate?.didPressPlayButton(in: self)
    }
}
