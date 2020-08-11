import Foundation
import ReSwift

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
