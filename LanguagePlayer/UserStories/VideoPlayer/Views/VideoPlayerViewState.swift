import Foundation

struct VideoPlayerViewState: Equatable {
    let tranlsation: TranslationViewState
    let navigationData: VideoPlayerNavigationData?
    
    init(appState: AppState) {
        let isLoading = appState.translationStatus.isLoading
        
        var source: String? = nil
        var target: String? = nil
        if case .success(let data) = appState.translationStatus.result,
            let t = data as? TranslationState {
            source = t.source
            target = t.target
        }
        
        self.tranlsation = TranslationViewState(
            translation: target,
            isAddedInDictionary: appState.translations.contains { $0.source == source },
            translating: isLoading
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
