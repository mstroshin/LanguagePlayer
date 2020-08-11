import Foundation

enum SupportedVideoFormat: String, Codable {
    case mp4 = "mp4"
    
    static func from(string: String) -> SupportedVideoFormat {
        guard let format = SupportedVideoFormat(rawValue: string) else {
            fatalError("Unsupported SupportedVideoFormat")
        }
        return format
    }
}

enum SupportedSubtitlesFormat: String, Codable {
    case srt = "srt"
    
    static func from(string: String) -> SupportedSubtitlesFormat {
        guard let format = SupportedSubtitlesFormat(rawValue: string) else {
            fatalError("Unsupported SupportedSubtitlesFormat")
        }
        return format
    }
}
