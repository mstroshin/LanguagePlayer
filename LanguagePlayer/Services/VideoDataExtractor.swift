import Foundation
import mobileffmpeg
import RxSwift
import RxCocoa

class VideoDataExtractor {
    struct VideoData {
        let extractedSubtitlesPaths: [URL]
        let audioTracksTitles: [String]
    }
    
    static func extractData(from filePath: URL) -> Single<VideoData> {
        Single.create { single -> Disposable in
            guard let path = filePath.absoluteString.removingPercentEncoding,
                  let mediaInfo = MobileFFprobe.getMediaInformation(path) else {
                let error = NSError(domain: "Media info is nil", code: 1, userInfo: nil)
                single(.error(error))
                return Disposables.create()
            }
            
            let subtitlePathsResult = self.extractSubtitles(from: mediaInfo, filePath: filePath)
            let audioTracksTitlesResult = self.extractAudio(from: mediaInfo)
            let data = VideoData(
                extractedSubtitlesPaths: (try? subtitlePathsResult.get()) ?? [],
                audioTracksTitles: (try? audioTracksTitlesResult.get()) ?? []
            )
            
            single(.success(data))
            
            return Disposables.create()
        }
    }
    
    private static func extractSubtitles(from mediaInfo: MediaInformation, filePath: URL) -> Result<[URL], Error> {
        guard let subtitleStreams = (mediaInfo.getStreams() as? [StreamInformation])?.filter({ $0.getType() == "subtitle" }) else {
            let error = NSError(domain: "Subtitle streams is nil", code: 1, userInfo: nil)
            return .failure(error)
        }
        var subtitlesPaths = [URL]()
        
        let pathToSave = filePath.deletingLastPathComponent()
        
        let path = filePath.absoluteString.removingPercentEncoding!
        var command = "-i \(path)"
        for subStream in subtitleStreams {
            guard let index = subStream.getIndex()?.intValue else {
                continue
            }
            let name = subStream.getTags()["title"] as? String ?? "subtitle"
            let language = subStream.getTags()["language"] as? String ?? ""
            let title = "\(index)_\(name)_\(language).srt"
            
            let subFile = pathToSave.appendingPathComponent(title).absoluteString
            command += " -map 0:\(index) \(subFile)"
            
            subtitlesPaths.append(URL(fileURLWithPath: subFile))
        }
        let result = MobileFFmpeg.execute(command)
        
        if result == RETURN_CODE_SUCCESS {
            return .success(subtitlesPaths)
        } else {
            let error = NSError(domain: "Extract subtitles error", code: Int(result), userInfo: nil)
            return .failure(error)
        }
    }
    
    private static func extractAudio(from mediaInfo: MediaInformation) -> Result<[String], Error> {
        guard let audioStreams = (mediaInfo.getStreams() as? [StreamInformation])?.filter({ $0.getType() == "audio" }) else {
            let error = NSError(domain: "Audio streams is nil", code: 1, userInfo: nil)
            return .failure(error)
        }
        
        var audioTitles = [String]()
        for (index, stream) in audioStreams.enumerated() {
            let name = stream.getTags()["title"] as? String ?? "track"
            let language = stream.getTags()["language"] as? String ?? ""
            let title = "\(index)_\(name)_\(language)"
            audioTitles.append(title)
        }
        
        return .success(audioTitles)
    }
    
}
