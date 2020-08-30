import ReSwift
import FirebaseAnalytics

func analyticsMiddleware() -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case let action as SaveVideo:
                    Analytics.logEvent("addedVideo", parameters: [
                        "videoFilename": action.video.fileName,
                        "sourceSubtitleFilename": action.sourceSubtitle?.fileName ?? ""
                    ])
                
                case let action as Translate:
                    Analytics.logEvent("tryTranslate", parameters: [
                        "text": action.source
                    ])
                case let action as TranslationResult:
                    if let data = action.data {
                        Analytics.logEvent("translated", parameters: [
                            "source": data.source,
                            "target": data.target
                        ])
                    }
                    else if let error = action.error {
                        Analytics.logEvent("translationError", parameters: [
                            "error": error.localizedDescription
                        ])
                    }
                    
                default:
                    break
                }
                
                next(action)
            }
        }
    }
}
