import Foundation
import RxSwift

class LocalDiskStore {
    private let fileManager = FileManager.default
        
    private func save(temporaryDataPath: URL, fileName: String, directoryName: String) -> Result<Void, Error> {
        if self.fileManager.fileExists(atPath: temporaryDataPath.path) == false {
            let error = NSError(
                domain: "TemporaryDataPath does not exist",
                code: 1,
                userInfo: ["temporaryDataPath": temporaryDataPath]
            )
            return .failure(error)
        }
        guard let documentsUrl = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            let error = NSError(domain: "documentsUrl does not exist", code: 1, userInfo: nil)
            return .failure(error)
        }
        
        do {
            let directoryPathUrl = documentsUrl.appendingPathComponent(directoryName)
            if !self.fileManager.fileExists(atPath: directoryPathUrl.path) {
                try self.fileManager.createDirectory(at: directoryPathUrl, withIntermediateDirectories: false, attributes: nil)
            }
            
            
            let urlToMove = directoryPathUrl.appendingPathComponent(fileName)
        
            try fileManager.moveItem(at: temporaryDataPath, to: urlToMove)
        } catch {
            return .failure(error)
        }
        
        return .success(())
    }
    
    func save(uploaded: UploadedVideo) -> Single<String> {
        Single.create { single -> Disposable in
            let directoryName = UUID().uuidString
            
            let videoSavedResult = self.save(
                temporaryDataPath: uploaded.video.temporaryDataPath,
                fileName: uploaded.video.fileName,
                directoryName: directoryName
            )
            var error: Error? = nil
            if case .failure(let er) = videoSavedResult {
                error = er
            }
            
            if error == nil {
                for subtitle in uploaded.subtitles {
                    let subtitleSavedResult = self.save(
                        temporaryDataPath: subtitle.temporaryDataPath,
                        fileName: subtitle.fileName,
                        directoryName: directoryName
                    )
                    if case .failure(let er) = subtitleSavedResult {
                        error = er
                        break
                    }
                }
            }
            
            if let error = error {
                single(.error(error))
            } else {
                single(.success(directoryName))
            }
            
            return Disposables.create()
        }
    }
    
    func removeDirectory(_ name: String) -> Bool {
        guard let documentsUrl = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let directoryPathUrl = documentsUrl.appendingPathComponent(name)
        
        do {
            try self.fileManager.removeItem(at: directoryPathUrl)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func url(for directoryName: String, fileName: String?) -> URL? {
        guard let fileName = fileName else { return nil }
        
        let documentsUrl = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPathUrl = documentsUrl.appendingPathComponent(directoryName)
        let videoUrl = directoryPathUrl.appendingPathComponent(fileName)
        
        if self.fileManager.fileExists(atPath: videoUrl.path) {
            return videoUrl
        } else {
            return nil
        }
    }
    
}
