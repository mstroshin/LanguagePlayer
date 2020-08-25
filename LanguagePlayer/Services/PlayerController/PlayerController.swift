import MobileVLCKit

typealias Milliseconds = Int

protocol PlayerControllerDelegate: class {
    func playerController(_ player: PlayerController, changed time: Milliseconds)
    func playerController(_ player: PlayerController, videoDuration: Milliseconds)
}

class PlayerController: NSObject {
    var videoId: ID = ""
    var currentTime: Milliseconds {
        if let value = self.player.time.value {
            return value.intValue
        }
        
        return 0
    }
    var videoDuration: Milliseconds {
        if let value = self.player.media.length.value {
            return value.intValue
        }
        
        return 0
    }
    weak var delegate: PlayerControllerDelegate?
    
    let player = VLCMediaPlayer()
    
    override init() {
        super.init()
        self.player.delegate = self
    }
    
    func set(viewport: UIView) {
        self.player.drawable = viewport
    }
    
    func set(videoUrl: URL) {
        self.player.media = VLCMedia(url: videoUrl)
    }
        
    func play() {
        self.player.play()
    }
    
    func pause() {
        self.player.pause()
    }
        
    func seek(to time: Milliseconds) {
        self.player.time = VLCTime(number: NSNumber(value: time))
    }
    
}

extension PlayerController: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        self.delegate?.playerController(self, changed: self.currentTime)
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if let duration = self.player.media.length.value?.intValue {
            self.delegate?.playerController(self, videoDuration: duration)
        }
    }
    
}
