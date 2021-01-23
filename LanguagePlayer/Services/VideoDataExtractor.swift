import Foundation
import mobileffmpeg
import RxSwift
import RxCocoa

struct ExtractedVideoData {
    let extractedSubtitlesPaths: [String]
    let audioTracksTitles: [String]
    let thumbnailImageFilePath: String
}

protocol VideoDataExtractor {
    func extractData(from filePath: String) -> Single<ExtractedVideoData>
}

class DefaultVideoDataExtractor: VideoDataExtractor {
    
    func extractData(from filePath: String) -> Single<ExtractedVideoData> {
        MobileFFmpegConfig.setLogLevel(AV_LOG_QUIET)
        
        return Single.create { single -> Disposable in
            guard let mediaInfo = MobileFFprobe.getMediaInformation(filePath) else {
                let error = NSError(domain: "Media info is nil", code: 1, userInfo: nil)
                single(.failure(error))
                return Disposables.create()
            }
            
            let subtitlePathsResult = self.extractSubtitlePaths(from: mediaInfo, filePath: filePath)
            let audioTracksTitlesResult = self.extractAudioTitles(from: mediaInfo)
            let thumbnailImagePathResult = self.extractThumbnailImagePath(fromVideo: filePath)
            let data = ExtractedVideoData(
                extractedSubtitlesPaths: (try? subtitlePathsResult.get()) ?? [],
                audioTracksTitles: (try? audioTracksTitlesResult.get()) ?? [],
                thumbnailImageFilePath: (try? thumbnailImagePathResult.get()) ?? ""
            )
            
            single(.success(data))
            
            return Disposables.create()
        }
    }
    
    private func extractSubtitlePaths(from mediaInfo: MediaInformation, filePath: String) -> Result<[String], Error> {
        guard let subtitleStreams = (mediaInfo.getStreams() as? [StreamInformation])?.filter({ $0.getType() == "subtitle" }) else {
            let error = NSError(domain: "Subtitle streams is nil", code: 1, userInfo: nil)
            return .failure(error)
        }
        var subtitlesPaths = [String]()
        
        let filePathUrl = URL(fileURLWithPath: filePath)
        let pathToSave = filePathUrl.deletingLastPathComponent()
        
        let path = filePath.removingPercentEncoding!
        var command = "-i \(path)"
        for subStream in subtitleStreams {
            guard let index = subStream.getIndex()?.intValue else {
                continue
            }
            let name = subStream.getTags()["title"] as? String ?? "subtitle"
            let language = subStream.getTags()["language"] as? String ?? ""
            let title = "\(index)_\(name)_\(language).srt"
            
            let subFileUrl = pathToSave.appendingPathComponent(title, isDirectory: false)
            command += " -map 0:\(index) \"\(subFileUrl.path)\""
            
            subtitlesPaths.append(subFileUrl.path)
        }
        let result = MobileFFmpeg.execute(command)
        
        if result == RETURN_CODE_SUCCESS {
            return .success(subtitlesPaths)
        } else {
            let error = NSError(domain: "Extract subtitles error", code: Int(result), userInfo: nil)
            return .failure(error)
        }
    }
    
    private func extractAudioTitles(from mediaInfo: MediaInformation) -> Result<[String], Error> {
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
    
    private func extractThumbnailImagePath(fromVideo path: String) -> Result<String, Error> {
        let name = "thumbnail.jpeg"
        let command = "-i \(path) -r 1 -an -t 12 -s 160x172 -vsync 1 -threads 4 \(name)"
        
        let result = MobileFFmpeg.execute(command)
        
        if result == RETURN_CODE_SUCCESS {
            let videoDirectoryUrl = URL(fileURLWithPath: path).deletingLastPathComponent()
            let thumbnailUrl = videoDirectoryUrl.appendingPathComponent(name)
            return .success(thumbnailUrl.path)
        } else {
            let error = NSError(domain: "Extract subtitles error", code: Int(result), userInfo: nil)
            return .failure(error)
        }
    }
    
}
