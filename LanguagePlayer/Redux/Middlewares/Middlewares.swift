import Foundation
import ReSwift

func filestoreMiddleware(filestore: LocalDiskStore) -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let action as AppStateActions.RemoveVideo:
                    let video = getState()?.videos.first { $0.id == action.id }
                    var successRemoved = false
                    
                    if let videoUrl = FileManager.default.url(for: video!.savedFileName + ".mp4") {
                        successRemoved = filestore.removeData(from: videoUrl)
                    }
                    if let sourceSubtitleUrl = FileManager.default.url(for: video!.savedFileName + ".srt") {
                        successRemoved = filestore.removeData(from: sourceSubtitleUrl)
                    }
                    print("Removed \(successRemoved)")
                    next(action)
                    
                case let action as AppStateActions.SaveVideo:
                    let fileName = UUID().uuidString
                    if filestore.save(data: action.video.data, fileName: fileName + ".mp4") &&
                        filestore.save(data: action.sourceSubtitle.data, fileName: fileName + ".srt") {
                        let action = AppStateActions.AddedVideo(
                            videoTitle: action.video.title,
                            savedFileName: fileName
                        )
                        next(action)
                        next(AppStateActions.SaveAppState())
                    } else {
                        print("Video was not saved")
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
