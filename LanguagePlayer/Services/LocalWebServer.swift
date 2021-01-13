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
                    print("Free space \(freeSpace)")
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
                guard let videoFilePath = self.getFilePath(for: "video", from: multiPartFormRequest) else {
                    return GCDWebServerResponse(statusCode: 500)
                }
                                
                let firstSubtitleFilePath = self.getFilePath(for: "firstSubtitle", from: multiPartFormRequest)
                let secondSubtitleFilePath = self.getFilePath(for: "secondSubtitle", from: multiPartFormRequest)
                let subtitles = [firstSubtitleFilePath, secondSubtitleFilePath].compactMap({$0})
                let video = UploadedVideo(videoPath: videoFilePath, subtitlePaths: subtitles)
                                
                observer.onNext(video)
                observer.onCompleted()
                
                return GCDWebServerResponse(statusCode: 200)
            }
            
            let serverIsRunning = webServer.start(withPort: 8080, bonjourName: "LanguagePlayer Server")
            print("Local WebServer is successfull running: \(String(describing: serverIsRunning))")
            
            return Disposables.create {
                webServer.stop()
                webServer.removeAllHandlers()
            }
        }
    }
    
    private func getFilePath(for name: String, from multiPart: GCDWebServerMultiPartFormRequest) -> URL? {
        if let part = multiPart.firstFile(forControlName: name) {
            let filePath = FileManager.rename(file: URL(fileURLWithPath: part.temporaryPath), to: part.fileName)
            return filePath
        }
        
        return nil
    }
    
}

extension LocalWebServer: GCDWebServerDelegate {
    
    func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
        let addresses = ServerAddresses(ip: server.serverURL?.absoluteString, bonjour: server.bonjourServerURL?.absoluteString)
        addressSubject.onNext(addresses)
    }
    
    func webServerDidStart(_ server: GCDWebServer) {
        let addresses = ServerAddresses(ip: server.serverURL?.absoluteString, bonjour: server.bonjourServerURL?.absoluteString)
        addressSubject.onNext(addresses)
    }
    
}
