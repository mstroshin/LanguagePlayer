import Foundation

class LocalDiskStore {
    
    func save(data: NSData) -> URL? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        guard let fileSaveUrl = URL(string: "name_for_file.txt", relativeTo: documentsUrl) else {
            return nil
        }
        print(fileSaveUrl)
        data.write(to: fileSaveUrl, atomically: true)
        
        return fileSaveUrl
    }
    
    func removeDate(from url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
}
