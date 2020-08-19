import AVKit
import UIKit
import ReSwift
import Combine

class VideoPlayerViewController: UIViewController {
    @IBOutlet private var subtitlesView: SubtitlesView!
    @IBOutlet private var controlsView: ControlsView!
    var playerController: PlayerController!
    var subtitlesExtractor: SubtitlesExtractor!
    
    private var currentSubtitle: SubtitlePart?
    private var cancellables = [AnyCancellable]()
    private weak var playerLayer: AVPlayerLayer?
    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.playerLayer?.frame = CGRect(origin: .zero, size: size)
            self.view.bringSubviewToFront(self.subtitlesView)
        }) { context in
            self.subtitlesView.updatePositions()
        }
    }
    
    private func setupViews() {
        self.subtitlesView.isHidden = true
        self.subtitlesView.delegate = self
        self.controlsView.delegate = self
    }
    
    //MARK: - Presenter input
    func show(player: AVPlayer) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        self.view.bringSubviewToFront(self.subtitlesView)
        
        self.playerLayer = playerLayer
    }
    
    func set(durationInSeconds: TimeInterval) {
        self.controlsView.set(durationInSeconds: durationInSeconds)
    }
    
    func updateTime(_ timeInMilliseconds: TimeInterval) {
        self.controlsView.set(timeInSeconds: timeInMilliseconds / 1000)
    }
        
    func startPlaying() {
        self.controlsView.isPlaying = true
        self.subtitlesView.deselectAll()
    }
    
    func stopPlaying() {
        self.controlsView.isPlaying = false
    }
    
    func show(subtitles: String) {
        if self.subtitlesView.currentText != subtitles {
            self.subtitlesView.set(text: subtitles)
            self.subtitlesView.isHidden = false
        }
    }
    
    func hideSubtitles() {
        self.subtitlesView.isHidden = true
    }
    
    func hideTranslation() {
        self.subtitlesView.hideTranslationView()
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
        
        let text = text.replacingOccurrences(of: "\n", with: " ")
        store.dispatch(AppStateActions.Translate(
            source: text,
            videoID: self.playerController.videoId,
            fromMilliseconds: subtitle.fromTime,
            toMilliseconds: subtitle.toTime
        ))
    }
    
    func addToDictionaryPressed() {
        store.dispatch(AppStateActions.ToogleCurrentTranslationFavorite())
        store.dispatch(AppStateActions.SaveAppState())
    }
    
}

extension VideoPlayerViewController: ControlsViewDelegate {
    
    func didPressClose() {
        self.playerController.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    func didPressBackwardFifteen() {
        self.hideTranslation()
        self.playerController.seek(timeInSeconds: self.playerController.currentTimeInSeconds - 15)
    }
    
    func didPressForwardFifteen() {
        self.hideTranslation()
        self.playerController.seek(timeInSeconds: self.playerController.currentTimeInSeconds + 15)
    }
    
    func didPressPlay() {
        self.playerController.play()
        self.startPlaying()
        self.hideTranslation()
    }
    
    func didPressPause() {
        self.playerController.pause()
        self.stopPlaying()
    }
    
    func didPressScreenTurn() {
        
    }
    
    func seekValueChangedSeekSlider(timeInSeconds: TimeInterval) {
        self.hideTranslation()
        self.playerController.seek(timeInSeconds: timeInSeconds)
    }
    
}

extension VideoPlayerViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = VideoPlayerViewState
    
    func newState(state: VideoPlayerViewState) {
        if let translation = state.tranlsation {
            self.subtitlesView.showTranslated(translation)
        }
        
        if state.afterNavigation {
            self.playerController = PlayerController(id: state.videoId!, url: state.videoUrl!)
            
            if let sourceSubtitleUrl = state.sourceSubtitleUrl {
                self.subtitlesExtractor = SubtitlesExtractorSrt(with: sourceSubtitleUrl)
            }
            
            self.show(player: self.playerController.avPlayer)
            
            let cancellable = self.playerController.setupTimePublisher().sink { timeInMilliseconds in
                self.updateTime(timeInMilliseconds)
                
                if let subtitle = self.subtitlesExtractor?.getSubtitle(for: timeInMilliseconds) {
                    self.currentSubtitle = subtitle
                    self.show(subtitles: subtitle.text)
                } else {
                    self.currentSubtitle = nil
                    self.hideSubtitles()
                }
            }
            self.cancellables.append(cancellable)
            
            self.set(durationInSeconds: self.playerController.videoDurationInSeconds)
            self.playerController.play()
            self.startPlaying()
        }
    }
}
