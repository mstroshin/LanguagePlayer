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
    private let addressSubject = ReplaySubject<ServerAddresses>.create(bufferSize: 1)
    var address: Observable<ServerAddresses> {
        addressSubject
            .asObservable()
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
                
                return GCDWebServerResponse(statusCode: 200)
            }
            
            do {
                try webServer.start(
                    options: [
                        GCDWebServerOption_ConnectionClass : LocalWebServerUploadConnection.self,
                        GCDWebServerOption_Port : 55511,
                        GCDWebServerOption_BonjourName : "LanguagePlayer Server"
                    ]
                )
            } catch {
                print("Local WebServer starting error: \(error)")
                observer.onError(error)
            }
            
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

class LocalWebServerUploadConnection: GCDWebServerConnection {
    private static let activitySubject = BehaviorSubject<Bool>(value: false)
    static var activity: Observable<Bool> {
        activitySubject.asObservable()
    }
    
    //Start
    override func rewriteRequest(_ url: URL, withMethod method: String, headers: [String : String]) -> URL {
        if url.lastPathComponent == "upload" {
            LocalWebServerUploadConnection.activitySubject.onNext(true)
        }
        
        return super.rewriteRequest(url, withMethod: method, headers: headers)
    }
    
    //Success
    override func processRequest(_ request: GCDWebServerRequest, completion: @escaping GCDWebServerCompletionBlock) {
        super.processRequest(request, completion: completion)
        
        if request.path.hasSuffix("/upload") {
            LocalWebServerUploadConnection.activitySubject.onNext(false)
        }
    }
    
    //Cancel
    override func abortRequest(_ request: GCDWebServerRequest?, withStatusCode statusCode: Int) {
        super.abortRequest(request, withStatusCode: statusCode)
        
        if let request = request, request.path.hasSuffix("/upload") {
            LocalWebServerUploadConnection.activitySubject.onNext(false)
        }
    }
    
}
