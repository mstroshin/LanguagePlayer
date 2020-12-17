import Foundation
import GCDWebServer
import RxSwift

struct UploadedFile {
    let fileName: String
    let temporaryDataPath: URL
}

struct UploadedVideo {
    let video: UploadedFile
    let subtitles: [UploadedFile]
}

struct ServerAddresses {
    let ip: String?
    let bonjour: String?
}

class LocalWebServer: NSObject {
    private let addressSubject = PublishSubject<ServerAddresses>()
    var address: Observable<ServerAddresses> {
        addressSubject.asObserver()
    }
    
//    private let webServer = GCDWebServer()
    private var fileParts = [GCDWebServerMultiPartFile]()
    
//    override init() {
//        super.init()
//
//        webServer.delegate = self
//
//        //Resources
//        webServer.addGETHandler(
//            forBasePath: "/",
//            directoryPath: Bundle.main.bundlePath,
//            indexFilename: "index.html",
//            cacheAge: 0,
//            allowRangeRequests: true
//        )
//    }
    
    func run() -> Observable<UploadedVideo> {
        Observable.create { observer -> Disposable in
            let webServer = GCDWebServer()
            webServer.delegate = self
            
            //Resources
            webServer.addGETHandler(
                forBasePath: "/",
                directoryPath: Bundle.main.bundlePath,
                indexFilename: "index.html",
                cacheAge: 0,
                allowRangeRequests: true
            )
            
            webServer.addHandler(
                forMethod: "POST",
                path: "/upload",
                request: GCDWebServerMultiPartFormRequest.self
            ) { r -> GCDWebServerResponse? in
                guard let multiPartFormRequest = r as? GCDWebServerMultiPartFormRequest else {
                    return GCDWebServerResponse(statusCode: 500)
                }
                guard let videoPart = multiPartFormRequest.firstFile(forControlName: "video") else {
                    return GCDWebServerResponse(statusCode: 500)
                }
//                self?.fileParts.append(videoPart)
                
                let videoFile = UploadedFile(
                    fileName: videoPart.fileName,
                    temporaryDataPath: URL(fileURLWithPath: videoPart.temporaryPath)
                )
                
                var firstSubtitleFile: UploadedFile? = nil
                if let firstSubtitlePart = multiPartFormRequest.firstFile(forControlName: "firstSubtitle") {
                    firstSubtitleFile =  UploadedFile(
                        fileName: firstSubtitlePart.fileName,
                        temporaryDataPath: URL(fileURLWithPath: firstSubtitlePart.temporaryPath)
                    )
//                    self?.fileParts.append(firstSubtitlePart)
                }
                var secondSubtitleFile: UploadedFile? = nil
                if let secondSubtitlePart = multiPartFormRequest.firstFile(forControlName: "secondSubtitle") {
                    secondSubtitleFile =  UploadedFile(
                        fileName: secondSubtitlePart.fileName,
                        temporaryDataPath: URL(fileURLWithPath: secondSubtitlePart.temporaryPath)
                    )
//                    self?.fileParts.append(secondSubtitlePart)
                }
                
                let subtitles = [firstSubtitleFile, secondSubtitleFile].compactMap({$0})
                let video = UploadedVideo(video: videoFile, subtitles: subtitles)
                observer.onNext(video)
                observer.onCompleted()
                
                return GCDWebServerResponse(statusCode: 200)
            }
            
            let serverIsRunning = webServer.start(withPort: 9099, bonjourName: "LanguagePlayer Server")
            print("Local WebServer is successfull running: \(String(describing: serverIsRunning))")
            
            return Disposables.create {
                webServer.stop()
            }
        }
    }
    
}

extension LocalWebServer: GCDWebServerDelegate {
    
    func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
        let addresses = ServerAddresses(ip: server.serverURL?.absoluteString, bonjour: server.bonjourServerURL?.absoluteString)
        addressSubject.onNext(addresses)
    }
    
}
