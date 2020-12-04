import Foundation
import mobileffmpeg
import RxSwift
import RxCocoa

class VideoDataExtractor: NSObject {
    struct VideoData {
        let subtitleNames: [String]
        let audioStreamNames: [String]
    }
    
    private var singleObserver: Single<VideoData>.SingleObserver?
    private var data: VideoData?
    
    func extractData(from filePath: URL) -> Single<VideoData> {
        Single.create { single -> Disposable in
            guard let mediaInfo = MobileFFprobe.getMediaInformation(filePath.absoluteString) else {
                let error = NSError(domain: "Media info is nil", code: 1, userInfo: nil)
                single(.error(error))
                return Disposables.create {
                    self.dispose()
                }
            }
            self.singleObserver = single
            
            let subtitleNamesResult = self.extractSubtitles(from: mediaInfo, filePath: filePath)
            let audioNamesResult = self.extractAudio(from: mediaInfo)
            self.data = VideoData(
                subtitleNames: (try? subtitleNamesResult.get()) ?? [],
                audioStreamNames: (try? audioNamesResult.get()) ?? []
            )
            
            return Disposables.create {
                self.dispose()
            }
        }
    }
    
    private func extractSubtitles(from mediaInfo: MediaInformation, filePath: URL) -> Result<[String], Error> {
        guard let subtitleStreams = (mediaInfo.getStreams() as? [StreamInformation])?.filter({ $0.getType() == "subtitle" }) else {
            let error = NSError(domain: "Subtitle streams is nil", code: 1, userInfo: nil)
            return .failure(error)
        }
        
        let pathToSave = filePath.deletingLastPathComponent()
        
        var subtitleNames = [String]()
        var command = "-i \(filePath.absoluteString)"
        for subStream in subtitleStreams {
            guard let index = subStream.getIndex()?.intValue else {
                continue
            }
            let title = subStream.getTags()["title"] as? String ?? "sub_\(index)"
            let lang = subStream.getTags()["language"] as? String ?? ""
            let name = "\(title)_\(lang).srt"
            subtitleNames.append(name)
            
            let subFile = pathToSave.appendingPathComponent(name).absoluteString
            command += " -map 0:\(index) \(subFile)"
        }
        let _ = MobileFFmpeg.executeAsync(command, withCallback: self)
        
        return .success(subtitleNames)
    }
    
    private func extractAudio(from mediaInfo: MediaInformation) -> Result<[String], Error> {
        guard let audioStreams = (mediaInfo.getStreams() as? [StreamInformation])?.filter({ $0.getType() == "audio" }) else {
            let error = NSError(domain: "Audio streams is nil", code: 1, userInfo: nil)
            return .failure(error)
        }
        
        var audioTitles = [String]()
        for (index, stream) in audioStreams.enumerated() {
            let name = stream.getTags()["title"] as? String ?? ""
            let language = stream.getTags()["language"] as? String ?? ""
            let title = "\(index)_\(name)_\(language)"
            audioTitles.append(title)
        }
        
        return .success(audioTitles)
    }
    
    private func dispose() {
        self.singleObserver = nil
        self.data = nil
    }
    
}

extension VideoDataExtractor: ExecuteDelegate {
    
    func executeCallback(_ executionId: Int, _ returnCode: Int32) {
        print(returnCode)
        if let data = self.data, returnCode == RETURN_CODE_SUCCESS {
            singleObserver?(.success(data))
        } else {
            let error = NSError(domain: "Something went wrong", code: Int(returnCode), userInfo: nil)
            singleObserver?(.error(error))
        }
        dispose()
    }
    
}
