import Foundation
import GCDWebServer
import RxSwift


struct UploadedVideo {
    let videoPath: URL
    let subtitlePaths: [URL]
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
                forMethod: "GET",
                path: "/freeSpace",
                request: GCDWebServerDataRequest.self) { request -> GCDWebServerResponse? in
                if let freeSpace = FileManager.deviceRemainingFreeSpaceInBytes() {
                    return GCDWebServerDataResponse(text: "\(freeSpace)")
                }
                
                return GCDWebServerResponse(statusCode: 500)
            }
            
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
                                
                var firstSubtitleFilePath: URL? = nil
                if let firstSubtitlePart = multiPartFormRequest.firstFile(forControlName: "firstSubtitle") {
                    firstSubtitleFilePath = URL(fileURLWithPath: firstSubtitlePart.temporaryPath)
                    firstSubtitleFilePath = FileManager.rename(file: firstSubtitleFilePath!, to: firstSubtitlePart.fileName)
                }
                var secondSubtitleFilePath: URL? = nil
                if let secondSubtitlePart = multiPartFormRequest.firstFile(forControlName: "secondSubtitle") {
                    secondSubtitleFilePath = URL(fileURLWithPath: secondSubtitlePart.temporaryPath)
                    secondSubtitleFilePath = FileManager.rename(file: secondSubtitleFilePath!, to: secondSubtitlePart.fileName)
                }
                
                if let newVideoPath = FileManager.rename(file: URL(fileURLWithPath: videoPart.temporaryPath), to: videoPart.fileName) {
                    let subtitles = [firstSubtitleFilePath, secondSubtitleFilePath].compactMap({$0})
                    let video = UploadedVideo(videoPath: newVideoPath, subtitlePaths: subtitles)
                    
                    observer.onNext(video)
                    observer.onCompleted()
                } else {
                    let error = NSError(domain: "Failed to rename video file", code: 1, userInfo: nil)
                    observer.onError(error)
                }
                
                return GCDWebServerResponse(statusCode: 200)
            }
            
            let serverIsRunning = webServer.start(withPort: 9099, bonjourName: "LanguagePlayer Server")
            print("Local WebServer is successfull running: \(String(describing: serverIsRunning))")
            
            return Disposables.create {
                webServer.stop()
                webServer.removeAllHandlers()
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
