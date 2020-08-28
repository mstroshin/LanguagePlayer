import Foundation

struct VideoPlayerViewState: Equatable {
    let tranlsation: TranslationViewState
    let navigationData: VideoPlayerNavigationData?
    
    init(appState: AppState) {
        self.tranlsation = TranslationViewState(
            translation: appState.currentTranslation?.target,
            isAddedInDictionary: appState.translations.contains { $0.source == appState.currentTranslation?.source },
            translating: appState.translating
        )
        self.navigationData = appState.navigation.isNavigating ? VideoPlayerNavigationData(appState) : nil
    }
}

struct VideoPlayerNavigationData: Equatable {
    let videoId: ID
    let videoUrl: URL
    let fromTime: Milliseconds
    let sourceSubtitleUrl: URL?
    let targetSubtitleUrl: URL?
    
    init(_ appState: AppState) {
        let videoId = appState.navigation.transiotionData!["videoId"] as! ID
        let video = appState.videos.first(where: { $0.id == videoId })!
        let localStore = LocalDiskStore()
        
        self.videoUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.fileName) ?? URL(string: "http://google.com")!
        self.sourceSubtitleUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.sourceSubtitleFileName)
        self.targetSubtitleUrl = localStore.url(for: video.savedInDirectoryName, fileName: video.targetSubtitleFileName)
        self.videoId = videoId
        
        self.fromTime = appState.navigation.transiotionData?["from"] as? Milliseconds ?? 0
    }
}
