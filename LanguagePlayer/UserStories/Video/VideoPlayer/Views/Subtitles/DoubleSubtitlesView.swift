import UIKit

class DoubleSubtitlesView: UIView {
    @IBOutlet weak var sourceSubtitleLabel: UILabel!
    @IBOutlet weak var targetSubtitleLabel: UILabel!
    
    func set(subtitles: DoubleSubtitles) {
        self.sourceSubtitleLabel.text = subtitles.source?.text
        self.targetSubtitleLabel.text = subtitles.target?.text
    }
}
