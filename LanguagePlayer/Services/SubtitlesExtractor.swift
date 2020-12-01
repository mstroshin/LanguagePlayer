import Foundation
import mobileffmpeg
import RxSwift
import RxCocoa

class SubtitlesExtractor: NSObject {
    private var singleObserver: Single<[URL]>.SingleObserver?
    private var subtitleUrls = [URL]()
    
    func extract(filePath: URL) -> Single<[URL]> {
        Single.create { single -> Disposable in
            guard let mediaInfo = MobileFFprobe.getMediaInformation(filePath.absoluteString) else {
                let error = NSError(domain: "Media info is nil", code: 1, userInfo: nil)
                single(.error(error))
                return Disposables.create {
                    self.dispose()
                }
            }
            guard let subtitleStreams = (mediaInfo.getStreams() as? [StreamInformation])?.filter({ $0.getType() == "subtitle" }) else {
                let error = NSError(domain: "Subtitle streams is nil", code: 1, userInfo: nil)
                single(.error(error))
                return Disposables.create {
                    self.dispose()
                }
            }
            self.singleObserver = single
            
            let pathToSave = filePath.deletingLastPathComponent()
            
            var command = "-i \(filePath.absoluteString)"
            for subStream in subtitleStreams {
                guard let index = subStream.getIndex()?.intValue else {
                    continue
                }
                let title = subStream.getTags()["title"] as? String ?? "sub_\(index)"
                let lang = subStream.getTags()["language"] as? String ?? ""
                let subFile = pathToSave.appendingPathComponent("\(title)_\(lang).srt")
                self.subtitleUrls.append(subFile)
                
                command += " -map 0:\(index) \(subFile.absoluteString)"
            }
            let _ = MobileFFmpeg.executeAsync(command, withCallback: self)
            
            return Disposables.create {
                self.dispose()
            }
        }
    }
    
    private func dispose() {
        self.singleObserver = nil
        self.subtitleUrls.removeAll()
    }
    
}

extension SubtitlesExtractor: ExecuteDelegate {
    
    func executeCallback(_ executionId: Int, _ returnCode: Int32) {
        print(returnCode)
        if returnCode == RETURN_CODE_SUCCESS {
            singleObserver?(.success(subtitleUrls))
        } else {
            let error = NSError(domain: "Something went wrong", code: Int(returnCode), userInfo: nil)
            singleObserver?(.error(error))
        }
        dispose()
    }
    
}
