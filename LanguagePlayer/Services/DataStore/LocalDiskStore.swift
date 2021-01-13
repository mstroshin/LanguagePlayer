import Foundation
import RxSwift

class LocalDiskStore {
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
        
    private func save(temporaryDataPath: URL, to directoryName: String) -> Result<Void, Error> {
        if fileManager.fileExists(atPath: temporaryDataPath.path) == false {
            let error = NSError(
                domain: "TemporaryDataPath does not exist",
                code: 1,
                userInfo: ["temporaryDataPath": temporaryDataPath]
            )
            return .failure(error)
        }
        
        do {
            let directoryPathUrl = documentsDirectory.appendingPathComponent(directoryName)
            if !fileManager.fileExists(atPath: directoryPathUrl.path) {
                try fileManager.createDirectory(at: directoryPathUrl, withIntermediateDirectories: false, attributes: nil)
            }
            
            let persistencePathUrl = directoryPathUrl.appendingPathComponent(temporaryDataPath.lastPathComponent)
            try fileManager.moveItem(at: temporaryDataPath, to: persistencePathUrl)
        } catch {
            return .failure(error)
        }
        
        return .success(())
    }
    
    func save(video: TemporaryVideo) -> Single<String> {
        Single.create { single -> Disposable in
            let directoryName = UUID().uuidString
            
            let videoSavedResult = self.save(
                temporaryDataPath: video.videoPath,
                to: directoryName
            )
            var error: Error? = nil
            if case .failure(let er) = videoSavedResult {
                error = er
            }
            
            if error == nil {
                for subtitleFilePath in video.subtitleFilesPaths {
                    let subtitleSavedResult = self.save(
                        temporaryDataPath: subtitleFilePath,
                        to: directoryName
                    )
                    if case .failure(let er) = subtitleSavedResult {
                        error = er
                        break
                    }
                }
            }
            
            if let error = error {
                single(.failure(error))
            } else {
                single(.success(directoryName))
            }
            
            return Disposables.create()
        }
    }
    
    func removeDirectory(_ name: String) -> Bool {
        let directoryPathUrl = documentsDirectory.appendingPathComponent(name)
        
        do {
            try fileManager.removeItem(at: directoryPathUrl)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func url(for directoryName: String, fileName: String?) -> URL? {
        guard let fileName = fileName else { return nil }
        
        let directoryPathUrl = documentsDirectory.appendingPathComponent(directoryName)
        let videoUrl = directoryPathUrl.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: videoUrl.path) {
            return videoUrl
        } else {
            return nil
        }
    }
    
}
