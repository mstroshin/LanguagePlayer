//
//  ControlsView.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 22.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import UIKit

protocol ControlsViewDelegate: class {
    func didPressClose()
    func didPressBackwardFifteen()
    func didPressForwardFifteen()
    func didPressPlay()
    func didPressPause()
    func didPressScreenTurn()
    func seekValueChangedSeekSlider(timeInSeconds: TimeInterval)
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
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var backwardFifteenButton: UIButton!
    @IBOutlet private weak var forwardFifteenButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var seekSlider: UISlider!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var screenTurnButton: UIButton!
    
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
    
    @IBAction private func valueChangedSeekSlider(_ sender: UISlider) {
        self.delegate?.seekValueChangedSeekSlider(timeInSeconds: TimeInterval(sender.value))
    }
    
    func set(durationInSeconds: TimeInterval) {
        self.seekSlider.minimumValue = 0
        self.seekSlider.maximumValue = Float(durationInSeconds)
    }
    
    func set(timeInSeconds: TimeInterval) {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        let formattedString = formatter.string(from: timeInSeconds)!
        self.timeLabel.text = formattedString
        
//        print(formattedString)
    }
    
}
