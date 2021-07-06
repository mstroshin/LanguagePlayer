//
//  VideoDownloadingViewModel.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 04.07.2021.
//

import Foundation
import Combine
import ffmpegkit

final class VideoDownloadingViewModel: ObservableObject {
    private let downloadingService = VideoDownloadingService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        downloadingService.start()

        downloadingService.$uploadedVideo.sink { video in
            print(video?.videoPath.absoluteString ?? "123")
        }.store(in: &cancellables)

        print(FFmpegKitConfig.version())
    }

}
