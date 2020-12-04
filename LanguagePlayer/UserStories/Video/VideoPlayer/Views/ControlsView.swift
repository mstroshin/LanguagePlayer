import Foundation
import UIKit

protocol ControlsViewDelegate: class {
    func didPressClose()
    func didPressBackwardFifteen()
    func didPressForwardFifteen()
    func didPressPlay()
    func didPressPause()
    func didPressScreenTurn()
    func seekValueChangedSeekSlider(time: Milliseconds)
    func didPressBackwardSub()
    func didPressForwardSub()
    func didPressToogleSubVisibility()
    func didPressSettings()
}

class ControlsView: UIView {
    weak var delegate: ControlsViewDelegate?
    var isPlaying = false {
        didSet {
            if isPlaying {
                self.playPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
            } else {
                self.playPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
            }
        }
    }
    
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var backwardFifteenButton: UIButton!
    @IBOutlet private weak var forwardFifteenButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var screenTurnButton: UIButton!
    @IBOutlet private weak var toogleSubVisibilityButton: UIButton!
    
    private var isValueChanging = false
    
    @IBAction private func didPressCloseButton(_ sender: UIButton) {
        self.delegate?.didPressClose()
    }
    
    @IBAction private func didPressBackwardFifteenButton(_ sender: UIButton) {
        self.delegate?.didPressBackwardFifteen()
    }
    
    @IBAction private func didPressForwardFifteenButton(_ sender: UIButton) {
        self.delegate?.didPressForwardFifteen()
    }
    
    @IBAction private func didPressPlayPauseButton(_ sender: UIButton) {
        if self.isPlaying {
            self.delegate?.didPressPause()
        } else {
            self.delegate?.didPressPlay()
        }
    }
    
    @IBAction private func didPressScreenTurnButton(_ sender: UIButton) {
        self.delegate?.didPressScreenTurn()
    }
    
    @IBAction func startChangingValue(_ sender: UISlider) {
        self.isValueChanging = true
    }
    
    @IBAction func stopChangingValue(_ sender: UISlider) {
        self.isValueChanging = false
    }
    
    @IBAction private func valueChangedSeekSlider(_ sender: UISlider) {
        self.delegate?.seekValueChangedSeekSlider(time: Milliseconds(sender.value))
    }
    
    @IBAction private func didPressBackwardSubButton(_ sender: UIButton) {
        self.delegate?.didPressBackwardSub()
    }
    
    @IBAction private func didPressForwardSubButton(_ sender: UIButton) {
        self.delegate?.didPressForwardSub()
    }
    
    @IBAction func didPressSubVisibilityButton(_ sender: UIButton) {
        self.delegate?.didPressToogleSubVisibility()
    }
    
    @IBAction func didPressSettingsButton(_ sender: UIButton) {
        self.delegate?.didPressSettings()
    }
    
    func subtitles(isVisible: Bool) {
        let image = isVisible ? UIImage(named: "sub_shown") : UIImage(named: "sub_hidden")
        self.toogleSubVisibilityButton.setImage(image, for: .normal)
    }
    
    func set(duration: Milliseconds) {
        self.seekSlider.minimumValue = 0
        self.seekSlider.maximumValue = Float(duration)
    }
    
    @objc func hideAnimated() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
    }
    
    func showAnimated() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }
    
    func toogleVisibility() {
        if self.alpha == 0 {
            self.showAnimated()
        } else {
            self.hideAnimated()
        }
    }
    
}
