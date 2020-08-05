import Foundation
import UIKit
import AVFoundation
import DifferenceKit

struct VideoListViewState {
    let videos: [VideoViewState]
    
    init(appState: AppState) {
        self.videos = appState.videos.map(VideoViewState.init)
    }
}

struct VideoViewState {
    let id: ID
    let videoTitle: String
    let videoUrl: URL
    let sourceSubtitleUrl: URL
    let videoPreviewImage: UIImage?
    
    init(video: VideoState) {
        self.id = video.id
        self.videoTitle = video.title
        self.videoUrl = FileManager.default.url(for: video.savedFileName + ".mp4")!
        self.sourceSubtitleUrl = FileManager.default.url(for: video.savedFileName + ".srt")!
        self.videoPreviewImage = createThumbnailOfVideo(from: self.videoUrl)
    }
}

extension VideoViewState: Differentiable {
    typealias DifferenceIdentifier = Int?

    var differenceIdentifier: Int? {
        return id
    }
    
    func isContentEqual(to source: VideoViewState) -> Bool {
        self.id == source.id
    }
}

fileprivate func createThumbnailOfVideo(from videoURL: URL) -> UIImage? {
    let asset = AVAsset(url: videoURL)
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(Float64(30), preferredTimescale: 100)
    do {
        let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: img)
        return thumbnail
    } catch {
        return nil
    }
}
