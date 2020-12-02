import MobileVLCKit
import RxSwift

typealias Milliseconds = Int

enum PlayerStatus {
    case unready
    case ready(duration: Milliseconds)
    case pause
    case play
}

class PlayerController: NSObject {
    //Inputs
    let seek: AnyObserver<Milliseconds>
    let isPlaying: AnyObserver<Bool>
    
    //Outputs
    let status = BehaviorSubject<PlayerStatus>(value: .unready)
    let currentTime = BehaviorSubject<Milliseconds>(value: 0)
    var videoDuration: Milliseconds {
        if let value = self.player.media.length.value {
            return value.intValue
        }
        
        return 0
    }
    
    //Privates
    private(set) var isPlayerReady = false
    private let player = VLCMediaPlayer()
    private let disposeBag = DisposeBag()
    
    init(videoUrl: URL) {
        self.player.media = VLCMedia(url: videoUrl)
        
        let isPlaying = PublishSubject<Bool>()
        self.isPlaying = isPlaying.asObserver()
        
        let seek = PublishSubject<Milliseconds>()
        self.seek = seek.asObserver()
        
        super.init()
        self.player.delegate = self
        
        isPlaying
            .subscribe(onNext: { [weak self] isPlaying in
                guard let self = self else { return }
                if isPlaying {
                    self.player.play()
                    self.status.onNext(.play)
                } else {
                    self.player.pause()
                    self.status.onNext(.pause)
                }
            })
            .disposed(by: disposeBag)
        
        seek.subscribe(onNext: { [weak self] time in
            guard let self = self else { return }
            self.player.time = VLCTime(number: NSNumber(value: time))
            if self.player.isPlaying == false {
                self.currentTime.onNext(time)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func set(viewport: UIView) {
        self.player.drawable = viewport
    }
    
}

extension PlayerController: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        if let time = self.player.time.value?.intValue {
            self.currentTime.onNext(time)
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        //Run once
        if let duration = self.player.media.length.value?.intValue, self.isPlayerReady == false {
            self.isPlayerReady = true
            
            //Disable inner subtitles
            self.player.currentVideoSubTitleIndex = -1
            
            //Choose english audio track
            let audioTrackNames = self.player.audioTrackNames as! [String]
            if audioTrackNames.count > 2 {
                if let (index, _) = audioTrackNames.enumerated().first(where: { $0.element.contains("en") }) {
                    self.player.currentAudioTrackIndex = Int32(index)
                }
            }
            
            //Send video duration
            status.onNext(.ready(duration: duration))
        }
    }
    
}
