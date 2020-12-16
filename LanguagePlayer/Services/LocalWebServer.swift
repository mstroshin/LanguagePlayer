import Foundation
import GCDWebServer
import RxSwift

struct UploadedFile {
    let fileName: String
    let temporaryDataPath: String
}

struct UploadedVideo {
    let video: UploadedFile
    let sourceSubtitle: UploadedFile?
    let targetSubtitle: UploadedFile?
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
    
    private let webServer = GCDWebServer()
    
    func run() -> Observable<UploadedVideo> {
        //Resources
        webServer.delegate = self
        webServer.addGETHandler(forBasePath: "/", directoryPath: Bundle.main.bundlePath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
        return Observable.create { [self] observer -> Disposable in
            webServer.addHandler(forMethod: "POST", path: "/upload", request: GCDWebServerMultiPartFormRequest.self) { r -> GCDWebServerResponse? in
                guard let multiPartFormRequest = r as? GCDWebServerMultiPartFormRequest else {
                    return GCDWebServerResponse(statusCode: 500)
                }
                guard let videoPart = multiPartFormRequest.firstFile(forControlName: "video") else {
                    return GCDWebServerResponse(statusCode: 500)
                }
                let videoFile = UploadedFile(
                    fileName: videoPart.fileName,
                    temporaryDataPath: videoPart.temporaryPath
                )
                
                var sourceSubtitleFile: UploadedFile? = nil
                if let sourceSubtitlePart = multiPartFormRequest.firstFile(forControlName: "firstSubtitle") {
                    sourceSubtitleFile =  UploadedFile(
                        fileName: sourceSubtitlePart.fileName,
                        temporaryDataPath: sourceSubtitlePart.temporaryPath
                    )
                }
                var targetSubtitleFile: UploadedFile? = nil
                if let targetSubtitlePart = multiPartFormRequest.firstFile(forControlName: "secondSubtitle") {
                    targetSubtitleFile =  UploadedFile(
                        fileName: targetSubtitlePart.fileName,
                        temporaryDataPath: targetSubtitlePart.temporaryPath
                    )
                }
                
                let video = UploadedVideo(video: videoFile, sourceSubtitle: sourceSubtitleFile, targetSubtitle: targetSubtitleFile)
                observer.onNext(video)
                observer.onCompleted()
                
                return GCDWebServerResponse(statusCode: 200)
            }
            
            let serverIsRunning = webServer.start(withPort: 9099, bonjourName: "LanguagePlayer Server")
            print("Local WebServer is successfull running: \(serverIsRunning)")
            
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
