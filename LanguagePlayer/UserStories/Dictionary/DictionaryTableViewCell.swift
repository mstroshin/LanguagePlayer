import Foundation
import UIKit

protocol DictionaryTableViewCellDelegate: class {
    func didPressPlayButton(in cell: DictionaryTableViewCell)
}

class DictionaryTableViewCell: UITableViewCell {
    static let identifier = String(describing: DictionaryTableViewCell.self)
    
    weak var delegate: DictionaryTableViewCellDelegate?
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var targetLabel: UILabel!
    @IBOutlet private weak var videoTitleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    
    func configure(with translation: DictionaryViewState.TranslationViewState) {
        self.sourceLabel.text = translation.source
        self.targetLabel.text = translation.target
        self.videoTitleLabel.text = translation.videoTitle
        
        self.playButton.isHidden = translation.videoId == nil 
    }
    
    @IBAction func didPressPlayButton(_ sender: UIButton) {
        self.delegate?.didPressPlayButton(in: self)
    }
}
