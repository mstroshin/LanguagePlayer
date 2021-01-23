import Foundation
import RxSwift
import RealmSwift
import RxSwiftExt

class VideoDownloader {
    
    struct TempVideoData {
        let videoPath: String
        let subtitleFilesPaths: [String]
        let audioStreamNames: [String]
        let thumbnailImagePath: String
    }
    
    let addresses: Observable<ServerAddresses>
    let downloadAndProcessVideo: Observable<TempVideoData>
    
    init(
        webServer: LocalWebServer = DefaultLocalWebServer(),
        dataExtractor: VideoDataExtractor = DefaultVideoDataExtractor()
    ) {
        self.addresses = webServer.addresses()
        let videoDownloaded = webServer.downloadVideo()
//            .share()
        
        let dataExtracted = videoDownloaded
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { video -> Single<ExtractedVideoData> in
                dataExtractor.extractData(from: video.videoPath)
            }
//            .share()
        
        self.downloadAndProcessVideo = Observable.zip(videoDownloaded, dataExtracted) { video, extractedData -> TempVideoData in
            TempVideoData(
                videoPath: video.videoPath,
                subtitleFilesPaths: video.subtitlePaths + extractedData.extractedSubtitlesPaths,
                audioStreamNames: extractedData.audioTracksTitles,
                thumbnailImagePath: extractedData.thumbnailImageFilePath
            )
        }
        .share()
    }
    
}
