import Foundation

class SettingsSharedModel {
    static let shared = SettingsSharedModel()
    
    @UserDefault("isPremium", defaultValue: false) var isPremium: Bool
    @UserDefault("sourceLanguageCode", defaultValue: "en") var sourceLanguageCode: String
    @UserDefault("targetLanguageCode", defaultValue: "ru") var targetLanguageCode: String
}
