import Foundation
import ReSwift
import Combine

func filestoreMiddleware(filestore: LocalDiskStore) -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let action as AppStateActions.RemoveVideo:
                    let video = getState()?.videos.first { $0.id == action.id }
                    let successRemoved = filestore.removeDirectory(video!.savedInDirectoryName)
 
                    print("Removed \(successRemoved)")
                    if successRemoved {
                        next(action)
                        next(AppStateActions.SaveAppState())
                    }
                    
                case let action as AppStateActions.SaveVideo:
                    let directoryName = UUID().uuidString
                    
                    let videoSaved = filestore.save(
                        temporaryDataPath: action.video.temporaryDataPath,
                        fileName: action.video.fileName,
                        directoryName: directoryName
                    )
                    if let sourceSubtitle = action.sourceSubtitle {
                        let sourceSubtitleSaved = filestore.save(
                            temporaryDataPath: sourceSubtitle.temporaryDataPath,
                            fileName: sourceSubtitle.fileName,
                            directoryName: directoryName
                        )
                        print("sourceSubtitleSaved \(sourceSubtitleSaved)")
                    }
                    if let targetSubtitle = action.targetSubtitle {
                        let targetSubtitleSaved = filestore.save(
                            temporaryDataPath: targetSubtitle.temporaryDataPath,
                            fileName: targetSubtitle.fileName,
                            directoryName: directoryName
                        )
                        print("targetSubtitleSaved \(targetSubtitleSaved)")
                    }
                    
                    if videoSaved {
                        let action = AppStateActions.AddedVideo(
                            videoFileName: action.video.fileName,
                            sourceSubtitleFileName: action.sourceSubtitle?.fileName,
                            targetSubtitleFileName: action.targetSubtitle?.fileName,
                            savedInDirectoryName: directoryName
                        )
                        next(action)
                        next(AppStateActions.SaveAppState())
                    }
                default:
                    next(action)
                }
            }
        }
    }
}

func userDefaultsMiddleware(userDefaults: UserDefaultsDataStore) -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case _ as AppStateActions.LoadAppState:
                    if let loadedState = userDefaults.loadAppState() {
                        next(AppStateActions.LoadedAppState(state: loadedState))
                    }
                case _ as AppStateActions.SaveAppState:
                    guard let state = getState() else { return }
                    userDefaults.save(appState: state)
                default:
                    next(action)
                }
            }
        }
    }
}

func translationMiddleware(translationService: TranslationService) -> Middleware<AppState> {
    var cancellable: AnyCancellable?
    
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let action as AppStateActions.Translate:
                    guard let state = getState() else { return }
                    if let translation = state.translationsHistory.first(where: { $0.source == action.source }) {
                        let data = TranslationModel(
                            source: translation.source,
                            target: translation.target,
                            videoID: translation.videoId,
                            fromTime: translation.fromTime,
                            toTime: translation.toTime
                        )
                        next(AppStateActions.AddTranslation(data: data))
                        return
                    }
                    
                    let text = action.source.replacingOccurrences(of: "\n", with: " ")
                    cancellable = translationService.translate(
                        text: text,
                        sourceLanguage: state.sourceLanguageCode,
                        targetLanguage: state.targetLanguageCode
                    )
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            print("translation error " + error.localizedDescription)
                        case .finished:
                            print("translation finished")
                        }
                    }) { translatedText in
                        let data = TranslationModel(
                            source: action.source,
                            target: translatedText,
                            videoID: action.videoID,
                            fromTime: action.fromTime,
                            toTime: action.toTime
                        )
                        next(AppStateActions.AddTranslation(data: data))
                        next(AppStateActions.AddTranslationToHistory(data: data))
                        next(AppStateActions.SaveAppState())
                    }
                default:
                    next(action)
                }
            }
        }
    }
}
