import UIKit
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
    
    init(video: VideoState) {        
        self.id = video.id
        self.videoTitle = video.fileName.components(separatedBy: ".").first!
        self.videoUrl = LocalDiskStore().url(for: video.savedInDirectoryName, fileName: video.fileName) ?? URL(fileURLWithPath: "")
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
