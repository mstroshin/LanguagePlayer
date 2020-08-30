import Foundation
import GCDWebServer
import ReSwift

class LocalWebServer: NSObject {
    let webServer = GCDWebServer()
    
    func run() {
        //Resources
        webServer.addGETHandler(forBasePath: "/", directoryPath: Bundle.main.bundlePath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
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
            if let sourceSubtitlePart = multiPartFormRequest.firstFile(forControlName: "sourceSubtitle") {
                sourceSubtitleFile =  UploadedFile(
                    fileName: sourceSubtitlePart.fileName,
                    temporaryDataPath: sourceSubtitlePart.temporaryPath
                )
            }
            var targetSubtitleFile: UploadedFile? = nil
            if let targetSubtitlePart = multiPartFormRequest.firstFile(forControlName: "targetSubtitle") {
                targetSubtitleFile =  UploadedFile(
                    fileName: targetSubtitlePart.fileName,
                    temporaryDataPath: targetSubtitlePart.temporaryPath
                )
            }
            
            let action = SaveVideo(
                video: videoFile,
                sourceSubtitle: sourceSubtitleFile,
                targetSubtitle: targetSubtitleFile
            )
            store.dispatch(action)
            
            return GCDWebServerResponse(statusCode: 200)
        }
            
        webServer.start(withPort: 9099, bonjourName: "GCD Web Server")
        webServer.delegate = self
    }
    
}

extension LocalWebServer: GCDWebServerDelegate {
    
    func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
        store.dispatch(ServerStarted(
            webServerIPAddress: server.serverURL?.absoluteString,
            webServerAddress: server.bonjourServerURL?.absoluteString
        ))
    }
    
}
