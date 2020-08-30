import ReSwift

func filestoreMiddleware(filestore: LocalDiskStore) -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let action as RemoveVideo:
                    let video = getState()?.videos.first { $0.id == action.id }
                    let successRemoved = filestore.removeDirectory(video!.savedInDirectoryName)
 
                    print("Removed \(successRemoved)")
                    if successRemoved {
                        next(action)
                    }
                case let action as SaveVideo:
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
                        let action = AddedVideo(
                            videoFileName: action.video.fileName,
                            sourceSubtitleFileName: action.sourceSubtitle?.fileName,
                            targetSubtitleFileName: action.targetSubtitle?.fileName,
                            savedInDirectoryName: directoryName
                        )
                        next(action)
                        next(SaveAppState())
                    }
                default:
                    next(action)
                }
            }
        }
    }
}
