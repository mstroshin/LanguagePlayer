import Foundation
import RxSwift
import RealmSwift

class UploadTutorialViewModel {
    let output: Output
    private let disposeBag = DisposeBag()
    
    init(
        webServer: LocalWebServer = LocalWebServer(),
        realm: Realm = try! Realm(),
        localStore: LocalDiskStore = LocalDiskStore()
    ) {
        self.output = Output(addresses: webServer.address)
        
        webServer.run()
            .observe(on: MainScheduler())
            .subscribe(onNext: { [self] uploaded in
                let directoryName = UUID().uuidString
                                    
                let videoSaved = localStore.save(
                    temporaryDataPath: uploaded.video.temporaryDataPath,
                    fileName: uploaded.video.fileName,
                    directoryName: directoryName
                )
                if let sourceSubtitle = uploaded.sourceSubtitle {
                    let sourceSubtitleSaved = localStore.save(
                        temporaryDataPath: sourceSubtitle.temporaryDataPath,
                        fileName: sourceSubtitle.fileName,
                        directoryName: directoryName
                    )
                    print("sourceSubtitleSaved \(sourceSubtitleSaved)")
                }
                if let targetSubtitle = uploaded.targetSubtitle {
                    let targetSubtitleSaved = localStore.save(
                        temporaryDataPath: targetSubtitle.temporaryDataPath,
                        fileName: targetSubtitle.fileName,
                        directoryName: directoryName
                    )
                    print("targetSubtitleSaved \(targetSubtitleSaved)")
                }
                
                if videoSaved {
                    let videoEntity = VideoEntity()
                    videoEntity.savedInDirectoryName = directoryName
                    videoEntity.fileName = uploaded.video.fileName
                    videoEntity.sourceSubtitleFileName = uploaded.sourceSubtitle?.fileName
                    videoEntity.targetSubtitleFileName = uploaded.targetSubtitle?.fileName
                    
                    try! realm.write {
                        realm.add(videoEntity)
                    }
                }
            },
            onCompleted: {
                //dismiss
            })
            .disposed(by: disposeBag)
    }
}

extension UploadTutorialViewModel {
    struct Output {
        let addresses: Observable<ServerAddresses>
    }
}
