import AVKit
import UIKit
import ReSwift
import Combine

class VideoPlayerViewController: UIViewController {
    @IBOutlet private var subtitlesView: SubtitlesView!
    @IBOutlet private var controlsView: ControlsView!
    @IBOutlet private var videoViewport: UIView!
    @IBOutlet private weak var subtitlesViewBottomConstraint: NSLayoutConstraint!
    
    let playerController = PlayerController()
    var subtitlesExtractor: SubtitlesExtractor!
    
    private var currentSubtitle: SubtitlePart?
    private var isSubtitlesEnable = true
    
    override func viewDidLoad() {
        self.setupViews()        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, transform: { $0.select(VideoPlayerViewState.init).skipRepeats() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.dispatch(NavigationActions.NavigationCompleted(currentScreen: .player))
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }
    
    private func setupViews() {
        self.subtitlesView.delegate = self
        self.controlsView.delegate = self
        
        self.playerController.delegate = self
        self.playerController.set(viewport: self.videoViewport)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.subtitlesViewBottomConstraint.constant = 0
        }
    }
    
    func set(duration: Milliseconds) {
        self.controlsView.set(duration: duration)
    }
    
    func updateTime(_ time: Milliseconds) {
        self.controlsView.set(time: time)
    }
        
    func startPlaying() {
        self.playerController.play()
        self.hideTranslation()
        self.controlsView.isPlaying = true
        self.subtitlesView.deselectAll()
        
        self.controlsView.perform(#selector(ControlsView.hideAnimated), with: nil, afterDelay: 1)
    }
    
    func stopPlaying() {
        self.playerController.pause()
        self.controlsView.isPlaying = false
    }
    
    func show(subtitles: String) {
        self.subtitlesView.set(text: subtitles)
        self.subtitlesView.isHidden = false
    }
    
    func hideSubtitles() {
        self.subtitlesView.isHidden = true
    }
    
    func hideTranslation() {
        self.subtitlesView.hideTranslationView()
    }
    
    @IBAction func didTapOnViewport(_ sender: UITapGestureRecognizer) {
        self.controlsView.toogleVisibility()
    }
    
}

extension VideoPlayerViewController: SubtitlesViewDelegate {
    
    func startedSelectingText(in subtitlesView: SubtitlesView) {
        self.playerController.pause()
        self.stopPlaying()
    }
    
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String) {
        guard let subtitle = self.currentSubtitle else { return }
        
        self.playerController.pause()
        self.stopPlaying()
        
        store.dispatch(Translate(
            source: text,
            videoID: self.playerController.videoId,
            fromTime: subtitle.fromTime,
            toTime: subtitle.toTime
        ))
        
//        let data = TranslationModel(
//            source: text,
//            target: text,
//            videoID: self.playerController.videoId,
//            fromTime: subtitle.fromTime,
//            toTime: subtitle.toTime
//        )
//        store.dispatch(TranslationResult(data: data, error: nil))
    }
    
    func addToDictionaryPressed() {
        store.dispatch(ToogleCurrentTranslationFavorite())
        store.dispatch(SaveAppState())
    }
    
}

extension VideoPlayerViewController: ControlsViewDelegate {
    
    func didPressClose() {
        self.playerController.pause()
        store.dispatch(ClearCurrentTranslation())
        self.dismiss(animated: true, completion: nil)
    }
    
    func didPressBackwardFifteen() {
        self.hideTranslation()
        store.dispatch(ClearCurrentTranslation())
        self.playerController.seek(to: self.playerController.currentTime - 15 * 1000)
    }
    
    func didPressForwardFifteen() {
        self.hideTranslation()
        store.dispatch(ClearCurrentTranslation())
        self.playerController.seek(to: self.playerController.currentTime + 15 * 1000)
    }
    
    func didPressPlay() {
        self.startPlaying()
    }
    
    func didPressPause() {
        self.stopPlaying()
    }
    
    //TODO
    func didPressScreenTurn() {
        
    }
    
    func seekValueChangedSeekSlider(time: Milliseconds) {
        self.hideTranslation()
        store.dispatch(ClearCurrentTranslation())
        self.playerController.seek(to: time)
    }
    
    func didPressBackwardSub() {
        if let subtitle = self.subtitlesExtractor?.getPreviousSubtitle(current: self.playerController.currentTime) {
            self.playerController.seek(to: subtitle.fromTime - 50)
        }
    }
    
    func didPressForwardSub() {
        if let subtitle = self.subtitlesExtractor?.getNextSubtitle(current: self.playerController.currentTime) {
            self.playerController.seek(to: subtitle.fromTime - 50)
        }
    }
    
    func didPressToogleSubVisibility() {
        self.subtitlesView.isHidden.toggle()
        self.controlsView.subtitles(isVisible: !self.subtitlesView.isHidden)
        self.isSubtitlesEnable.toggle()
    }
    
}

extension VideoPlayerViewController: PlayerControllerDelegate {
    
    func playerController(_ player: PlayerController, changed time: Milliseconds) {
        self.updateTime(time)
        
        if self.isSubtitlesEnable {
            if let subtitle = self.subtitlesExtractor?.getSubtitle(for: time) {
                if self.currentSubtitle?.number != subtitle.number {
                    self.currentSubtitle = subtitle
                    self.show(subtitles: subtitle.text)
                }
            } else if self.currentSubtitle != nil {
                self.currentSubtitle = nil
                self.hideSubtitles()
            }
        }
    }
    
    func playerController(_ player: PlayerController, videoDuration: Milliseconds) {
        self.set(duration: videoDuration)
    }
    
}

extension VideoPlayerViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = VideoPlayerViewState
    
    func newState(state: VideoPlayerViewState) {
        DispatchQueue.main.async {
            if state.tranlsation.translating == false && state.tranlsation.translation == nil {
                self.subtitlesView.hideTranslationView()
            } else {
                self.subtitlesView.showTranslated(state.tranlsation)
            }
            
            if let navigationData = state.navigationData {
                self.playerController.set(videoUrl: navigationData.videoUrl)
                self.playerController.videoId = navigationData.videoId
                
                if let sourceSubtitleUrl = navigationData.sourceSubtitleUrl {
                    self.subtitlesExtractor = SubtitlesExtractorSrt(with: sourceSubtitleUrl)
                }
                
                self.startPlaying()
                self.playerController.seek(to: navigationData.fromTime)
            }
        }
    }
}
