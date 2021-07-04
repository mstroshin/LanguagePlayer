//
//  WebServerUploadConnection.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 04.07.2021.
//

import Foundation
import GDCWebServer

final class WebServerUploadConnection: GCDWebServerConnection {
    //Start
    override func rewriteRequest(_ url: URL, withMethod method: String, headers: [String : String]) -> URL {
        if url.lastPathComponent == "upload" {
            VideoDownloadingService.shared.activity = true
        }

        return super.rewriteRequest(url, withMethod: method, headers: headers)
    }

    //Success
    override func processRequest(_ request: GCDWebServerRequest, completion: @escaping GCDWebServerCompletionBlock) {
        super.processRequest(request, completion: completion)

        if request.path.hasSuffix("/upload") {
            VideoDownloadingService.shared.activity = false
        }
    }

    //Cancel
    override func abortRequest(_ request: GCDWebServerRequest?, withStatusCode statusCode: Int) {
        super.abortRequest(request, withStatusCode: statusCode)

        if let request = request, request.path.hasSuffix("/upload") {
            VideoDownloadingService.shared.activity = false
        }
    }
}
