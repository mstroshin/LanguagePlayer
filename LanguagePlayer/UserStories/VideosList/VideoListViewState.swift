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
    let sourceSubtitleUrl: URL?
    let targetSubtitleUrl: URL?
    let videoPreviewImage: UIImage?
    
    init(video: VideoState) {
        let localStore = LocalDiskStore()
        
        self.id = video.id
        self.videoTitle = video.fileName.components(separatedBy: ".").first!
        self.videoUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.fileName)!
        self.sourceSubtitleUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.sourceSubtitleFileName)
        self.targetSubtitleUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.targetSubtitleFileName)
        self.videoPreviewImage = createThumbnailOfVideo(from: self.videoUrl)
    }
}

extension VideoViewState: Differentiable {
    typealias DifferenceIdentifier = ID?

    var differenceIdentifier: ID? {
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
