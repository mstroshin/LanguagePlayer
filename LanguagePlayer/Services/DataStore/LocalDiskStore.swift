import Foundation

class LocalDiskStore {
    let fileManager = FileManager.default
        
    func save(temporaryDataPath path: String, fileName: String, directoryName: String) -> Bool {
        guard let documentsUrl = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        do {
            let directoryPathUrl = documentsUrl.appendingPathComponent(directoryName)
            if !self.fileManager.fileExists(atPath: directoryPathUrl.path) {
                try self.fileManager.createDirectory(at: directoryPathUrl, withIntermediateDirectories: false, attributes: nil)
            }
            
            let temporaryDataUrl = URL(fileURLWithPath: path)
            let urlToMove = directoryPathUrl.appendingPathComponent(fileName)
        
            try fileManager.moveItem(at: temporaryDataUrl, to: urlToMove)
        } catch {
            print(error)
            return false
        }
        
        return true
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
