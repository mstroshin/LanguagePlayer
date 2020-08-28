import ReSwift
import Foundation

typealias ID = String

struct AppState: StateType {
    var navigation = NavigationState()
    
    var sourceLanguageCode = "en"
    var targetLanguageCode = "ru"
    
    var webServerIPAddress: String?
    var webServerAddress: String?
    
    var videos = [VideoState]()
    
    //Keeps added to Dictionary words
    var translations = [TranslationState]()
    
    //Keeps every translated word
    var translationsHistory = [TranslationState]()
    
    var currentTranslation: TranslationState?
    var translating: Bool = false
}

extension AppState: Codable {
    enum CodingKeys: String, CodingKey {
        case sourceLanguageCode
        case targetLanguageCode
        case videos
        case translations
        case translationsHistory
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sourceLanguageCode = try container.decode(String.self, forKey: .sourceLanguageCode)
        self.targetLanguageCode = try container.decode(String.self, forKey: .targetLanguageCode)
        self.videos = try container.decode([VideoState].self, forKey: .videos)
        self.translations = try container.decode([TranslationState].self, forKey: .translations)
        self.translationsHistory = try container.decode([TranslationState].self, forKey: .translationsHistory)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sourceLanguageCode, forKey: .sourceLanguageCode)
        try container.encode(targetLanguageCode, forKey: .targetLanguageCode)
        try container.encode(videos, forKey: .videos)
        try container.encode(translations, forKey: .translations)
        try container.encode(translationsHistory, forKey: .translationsHistory)
    }
}

struct VideoState: Codable {
    let id: ID
    let savedInDirectoryName: String
    let fileName: String
    let sourceSubtitleFileName: String?
    let targetSubtitleFileName: String?
}

struct TranslationState: Codable {
    let id: ID
    let videoId: ID
    let source: String
    let target: String
    let fromTime: Milliseconds
    let toTime: Milliseconds
    
    init(from model: TranslationModel) {
        self.id = UUID().uuidString
        self.videoId = model.videoID
        self.source = model.source
        self.target = model.target
        self.fromTime = model.fromTime
        self.toTime = model.toTime
    }
}
