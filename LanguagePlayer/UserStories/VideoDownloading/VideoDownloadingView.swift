//
//  VideoDownloadingView.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 04.07.2021.
//

import SwiftUI

struct VideoDownloadingView: View {
    @ObservedObject var viewModel = VideoDownloadingViewModel()

    var body: some View {
        Text("Hello, World!")
    }
}

struct VideoDownloadingView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDownloadingView()
    }
}
