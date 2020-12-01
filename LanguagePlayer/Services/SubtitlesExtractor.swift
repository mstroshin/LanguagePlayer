import Foundation
import mobileffmpeg

class SubtitlesExtractor {
    
    static func extract(filePath: URL) -> Bool {
        guard let mediaInfo = MobileFFprobe.getMediaInformation(filePath.absoluteString) else {
            return false
        }
        guard let subtitleStreams = (mediaInfo.getStreams() as? [StreamInformation])?.filter({ $0.getType() == "subtitle" }) else {
            return false
        }
        
        let pathToSave = filePath.deletingLastPathComponent()
        for subStream in subtitleStreams {
            guard let index = subStream.getIndex()?.intValue else {
                continue
            }
            let title = subStream.getTags()["title"] as? String ?? "sub_\(index)"
            let lang = subStream.getTags()["language"] as? String ?? ""
            let subFile = pathToSave.appendingPathComponent("\(title)_\(lang).srt").absoluteString
            
            let rc = MobileFFmpeg.execute("-i \(filePath) -map 0:\(index) \(subFile)")
            print(rc)
        }
        
        return true
    }
    
}
