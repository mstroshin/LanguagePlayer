//
//  VideoUploaderManager.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 26.10.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import RealmSwift

class VideoUploaderManager {
    let filestore = LocalDiskStore()
//    let webServer = LocalWebServer.shared
    let realm = try! Realm()
    
    /*
    func listenWebServer() {
        webServer.uploaded = { [weak self] video, source, target in
            guard let self = self else { return }
            let directoryName = UUID().uuidString
            
            let videoSaved = self.filestore.save(
                temporaryDataPath: video.temporaryDataPath,
                fileName: video.fileName,
                directoryName: directoryName
            )
            if let sourceSubtitle = source {
                let sourceSubtitleSaved = self.filestore.save(
                    temporaryDataPath: sourceSubtitle.temporaryDataPath,
                    fileName: sourceSubtitle.fileName,
                    directoryName: directoryName
                )
                print("sourceSubtitleSaved \(sourceSubtitleSaved)")
            }
            if let targetSubtitle = target {
                let targetSubtitleSaved = self.filestore.save(
                    temporaryDataPath: targetSubtitle.temporaryDataPath,
                    fileName: targetSubtitle.fileName,
                    directoryName: directoryName
                )
                print("targetSubtitleSaved \(targetSubtitleSaved)")
            }
            
            if videoSaved {
                DispatchQueue.main.async {
                    let videoEntity = VideoEntity()
                    videoEntity.fileName = video.fileName
                    videoEntity.savedInDirectoryName = directoryName
                    videoEntity.sourceSubtitleFileName = source?.fileName
                    videoEntity.targetSubtitleFileName = target?.fileName
                    
                    try! self.realm.write {
                        self.realm.add(videoEntity)
                    }
                }
                
            }
        }
    }
 */
}
