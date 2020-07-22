//
//  PlayerController.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import AVKit
import Combine

class PlayerController {
    let timeInMillisecondsPublisher = PassthroughSubject<TimeInterval, Never>()
    var currentTimeInMilliseconds: TimeInterval {
        self.currentTimeInSeconds * 1000
    }
    var currentTimeInSeconds: TimeInterval {
        self.avPlayer.currentTime().seconds
    }
    var videoDurationInSeconds: TimeInterval {
        self.avPlayer.currentItem?.asset.duration.seconds ?? 0
    }
    
    let avPlayer: AVPlayer
    private var timeObservation: Any?
    
    init(url: URL) {
        self.avPlayer = AVPlayer(url: url)
    }
    
    deinit {
        if let timeObservation = self.timeObservation {
            self.avPlayer.removeTimeObserver(timeObservation)
        }
    }
    
    func setupTimePublisher(updatePeriodicInSeconds: TimeInterval = 0.1) -> PassthroughSubject<TimeInterval, Never> {
        self.timeObservation = self.avPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: updatePeriodicInSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            self.timeInMillisecondsPublisher.send(time.seconds * 1000)
        }
    
        return self.timeInMillisecondsPublisher
    }
    
    func play() {
        self.avPlayer.play()
    }
    
    func pause() {
        self.avPlayer.pause()
    }
    
    func seek(timeInSeconds: TimeInterval) {
        self.avPlayer.seek(to: CMTime(seconds: timeInSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
}
