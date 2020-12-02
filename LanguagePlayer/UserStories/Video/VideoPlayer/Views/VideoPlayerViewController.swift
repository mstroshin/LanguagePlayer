import AVKit
import UIKit
import RxSwift
import RxCocoa

class VideoPlayerViewController: UIViewController {
    var viewModel: VideoPlayerViewModel!

    @IBOutlet private var subtitlesView: SubtitlesView!
    @IBOutlet private var controlsView: ControlsView!
    @IBOutlet private var videoViewport: UIView!
    @IBOutlet private weak var subtitlesViewBottomConstraint: NSLayoutConstraint!
    private var isSubtitlesEnable = true
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        setupViews()
        super.viewDidLoad()
        
        self.setupBindings()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    
    private func setupViews() {
        controlsView.delegate = self
        
        viewModel.set(viewport: self.videoViewport)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            subtitlesViewBottomConstraint.constant = 0
        }
    }
    
    private func setupBindings() {
        //Time label
        viewModel.output.currentTime
            .map(millisecondsToTime(_:))
            .drive(controlsView.timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        //Slider
        viewModel.output.currentTime
            .map { Float($0) }
            .drive(onNext: { time in
                self.controlsView.seekSlider.value = time
            })
            .disposed(by: disposeBag)
        
        //Player statuses
        viewModel.output.playerStatus
            .drive(onNext: { status in
                switch status {
                case .unready:
                    break
                case .ready(let duration):
                    self.controlsView.set(duration: duration)
                case .pause:
                    self.controlsView.isPlaying = false
                case .play:
                    self.controlsView.isPlaying = true
                    self.subtitlesView.deselectAll()

                    self.controlsView.perform(#selector(ControlsView.hideAnimated), with: nil, afterDelay: 1)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.currentSubtitles?
            .drive(onNext: { subtitles in
                //TODO:
            })
            .disposed(by: disposeBag)
    }
    
    private func millisecondsToTime(_ milliseconds: Milliseconds) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        return formatter.string(from: TimeInterval(milliseconds / 1000))!
    }
    
    @IBAction func didTapOnViewport(_ sender: UITapGestureRecognizer) {
        self.controlsView.toogleVisibility()
    }
    
}


extension VideoPlayerViewController: ControlsViewDelegate {
    
    func didPressClose() {
        viewModel.input.close.onCompleted()
    }
    
    func didPressBackwardFifteen() {
//        let time = try! viewModel.output.currentTime - 15 * 1000
//        playerController.seek(to: time)
//        viewModel.input.seek.onNext(0)
    }
    
    func didPressForwardFifteen() {
//        let time = try! playerController.currentTime.value() + 15 * 1000
//        playerController.seek(to: time)
    }
    
    func didPressPlay() {
        viewModel.input.isPlaying.onNext(true)
    }
    
    func didPressPause() {
        viewModel.input.isPlaying.onNext(false)
    }
    
    
    func didPressScreenTurn() {
        //TODO:
    }
    
    func seekValueChangedSeekSlider(time: Milliseconds) {
        viewModel.input.seek.onNext(time)
    }
    
    func didPressBackwardSub() {
        viewModel.input.backwardSub.onNext(())
    }
    
    func didPressForwardSub() {
        viewModel.input.forwardSub.onNext(())
    }
    
    func didPressToogleSubVisibility() {
        let isHidden = self.subtitlesView.isHidden
        
        self.subtitlesView.isHidden = !isHidden
        self.controlsView.subtitles(isVisible: isHidden)
        self.isSubtitlesEnable = isHidden
    }
    
}
