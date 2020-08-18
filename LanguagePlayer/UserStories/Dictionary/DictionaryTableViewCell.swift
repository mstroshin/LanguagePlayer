import Foundation
import UIKit

class DictionaryTableViewCell: UITableViewCell {
    static let identifier = String(describing: DictionaryTableViewCell.self)
    
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var targetLabel: UILabel!
    @IBOutlet private weak var videoTitleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    
    
    func configure(with translation: DictionaryViewState.TranslationViewState) {
        self.sourceLabel.text = translation.source
        self.targetLabel.text = translation.target
        self.videoTitleLabel.text = translation.videoTitle
    }
    
    @IBAction func didPressPlayButton(_ sender: UIButton) {
        
    }
}
