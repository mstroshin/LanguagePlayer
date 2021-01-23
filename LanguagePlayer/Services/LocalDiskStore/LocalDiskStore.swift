import Foundation
import RxSwift

protocol LocalDiskStore {
    func moveFileInDocuments(fromPath: String, subdirectoryName: String) -> Single<Void>
    func removeFile(at path: String) -> Single<Void>
}

class DefaultLocalDiskStore: LocalDiskStore {
    private let fileManager: FileManager
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func moveFileInDocuments(fromPath: String, subdirectoryName: String) -> Single<Void> {
        Single.create { observer -> Disposable in
            if self.fileManager.fileExists(atPath: fromPath) == false {
                let error = NSError(
                    domain: "File does not exit at path",
                    code: 1,
                    userInfo: ["path": fromPath]
                )
                observer(.failure(error))
                return Disposables.create()
            }
            
            do {
                let directoryPathUrl = self.documentsDirectory.appendingPathComponent(subdirectoryName)
                if !self.fileManager.fileExists(atPath: directoryPathUrl.path) {
                    try self.fileManager.createDirectory(at: directoryPathUrl, withIntermediateDirectories: false, attributes: nil)
                }
                
                let entityPathURL = URL(fileURLWithPath: fromPath)
                let persistencePathUrl = directoryPathUrl.appendingPathComponent(entityPathURL.lastPathComponent)
                try self.fileManager.moveItem(at: entityPathURL, to: persistencePathUrl)
                
                observer(.success(()))
            } catch {
                observer(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func removeFile(at path: String) -> Single<Void> {
        Single.create { observer -> Disposable in
            do {
                try self.fileManager.removeItem(atPath: path)
                observer(.success(()))
            } catch {
                observer(.failure(error))
            }
            
            return Disposables.create()
        }
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
    
}
