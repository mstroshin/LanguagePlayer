import Foundation

class LocalDiskStore {
    
    func save(data: Data, fileName: String) -> Bool {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        guard let fileSaveUrl = URL(string: fileName, relativeTo: documentsUrl) else {
            return false
        }
        let success = NSData(data: data).write(to: fileSaveUrl, atomically: true)
        if success {
            print("Saved file: \(fileSaveUrl.absoluteString)")
        } else {
            print("Did not save file: \(fileSaveUrl.absoluteString)")
        }
        
        return success
    }
    
    func removeData(from url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
}
