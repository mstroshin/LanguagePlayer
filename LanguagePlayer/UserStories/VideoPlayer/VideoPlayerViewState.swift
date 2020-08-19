import Foundation

struct VideoPlayerViewState: Equatable {
    let tranlsation: TranslationViewState?
    
    let afterNavigation: Bool
    let videoId: ID?
    let videoUrl: URL?
    let sourceSubtitleUrl: URL?
    let targetSubtitleUrl: URL?
    
    init(appState: AppState) {
        if let translation = appState.currentTranslation {
            let isAddedInDictionary = appState.translations.contains { $0.source == translation.source }
            self.tranlsation = TranslationViewState(
                translation: translation.target,
                isAddedInDictionary: isAddedInDictionary
            )
        } else {
            self.tranlsation = nil
        }
        
        let transiotionData = appState.navigation.transiotionData
        self.afterNavigation = transiotionData != nil
        
        if let transiotionData = transiotionData {
            let videoId = transiotionData["videoId"] as! ID
            let video = appState.videos.first(where: { $0.id == videoId })!
            let localStore = LocalDiskStore()
            
            self.videoUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.fileName) ?? URL(string: "http://google.com")!
            self.sourceSubtitleUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.sourceSubtitleFileName)
            self.targetSubtitleUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.targetSubtitleFileName)
            self.videoId = videoId
        } else {
            self.videoUrl = nil
            self.sourceSubtitleUrl = nil
            self.targetSubtitleUrl = nil
            self.videoId = nil
        }
    }
}
