import ReSwift

func translationMiddleware(translationService: TranslationService) -> Middleware<AppState> {
    return { dispatch, getState in
        return { next in
            return { action in
                switch action {
                case _ as GetAvailableLanguages:
                    translationService.availableLanguageCodes { result in
                        switch result {
                        case .failure(_):
                            next(SaveAvailableLanguages(languages: []))
                        case .success(let languages):
                            next(SaveAvailableLanguages(languages: languages))
                        }
                        next(SaveAppState())
                    }
                    
                case let action as Translate:
                    guard let state = getState() else { return }
                    if let translation = state.translationsHistory.first(where: { $0.source == action.source }) {
                        let data = TranslationModel(
                            source: translation.source,
                            target: translation.target,
                            videoID: translation.videoId,
                            fromTime: translation.fromTime,
                            toTime: translation.toTime
                        )
                        next(TranslationResult(data: data, error: nil))
                        return
                    }
                    
                    next(Translating())
                    
                    let text = action.source.replacingOccurrences(of: "\n", with: " ")
                    translationService.translate(
                        text: text,
                        sourceLanguage: state.settings.selectedSourceLanguage.code,
                        targetLanguage: state.settings.selectedTargetLanguage.code
                    ) { result in
                        switch result {
                        case .failure(let error):
                            next(TranslationResult(data: nil, error: error))
                        case .success(let translatedText):
                            let data = TranslationModel(
                                source: action.source,
                                target: translatedText,
                                videoID: action.videoID,
                                fromTime: action.fromTime,
                                toTime: action.toTime
                            )
                            next(TranslationResult(data: data, error: nil))
                            next(AddTranslationToHistory(data: data))
                            next(SaveAppState())
                        }
                    }
                default:
                    next(action)
                }
            }
        }
    }
}
