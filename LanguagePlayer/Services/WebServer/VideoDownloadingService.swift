//
//  VideoDownloadingService.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 04.07.2021.
//

import Foundation
import GCDWebServer

struct UploadedVideo {
    let videoPath: URL
    let subtitlePaths: [URL]
}

struct ServerAddresses {
    let ip: String?
    let bonjour: String?
}

final class VideoDownloadingService {
    static var shared = VideoDownloadingService()
    private let webServer = GCDWebServer()

    @Published var activity: Bool = false
    @Published var uploadedVideo: UploadedVideo?

    private init() {
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
            guard let videoFilePath = self.getFilePath(for: "video", from: multiPartFormRequest) else {
                return GCDWebServerResponse(statusCode: 500)
            }

            let firstSubtitleFilePath = self.getFilePath(for: "firstSubtitle", from: multiPartFormRequest)
            let secondSubtitleFilePath = self.getFilePath(for: "secondSubtitle", from: multiPartFormRequest)
            let subtitles = [firstSubtitleFilePath, secondSubtitleFilePath].compactMap({$0})
            let video = UploadedVideo(videoPath: videoFilePath, subtitlePaths: subtitles)

            self.uploadedVideo = video

            return GCDWebServerResponse(statusCode: 200)
        }

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
    }

    deinit {
        webServer.stop()
        webServer.removeAllHandlers()
    }

    private func getFilePath(for name: String, from multiPart: GCDWebServerMultiPartFormRequest) -> URL? {
        if let part = multiPart.firstFile(forControlName: name) {
            let filePath = FileManager.rename(file: URL(fileURLWithPath: part.temporaryPath), to: part.fileName)
            return filePath
        }

        return nil
    }

    func start() {
        do {
            try webServer.start(
                options: [
                    GCDWebServerOption_ConnectionClass : WebServerUploadConnection.self,
                    GCDWebServerOption_Port : 55511,
                    GCDWebServerOption_BonjourName : "LanguagePlayer Server"
                ]
            )
        } catch {
            print("Local WebServer starting error: \(error)")
        }
    }


}
