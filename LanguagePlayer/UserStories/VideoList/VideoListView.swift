//
//  ContentView.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 04.07.2021.
//

import SwiftUI

struct VideoListView: View {
    @State private var presentingVideoDownloading = false

    var body: some View {
        NavigationView {
            Text("Hello, world!")
                .padding()
                .navigationTitle("Videos")
                .toolbar(content: {
                    Button(action: {
                        presentingVideoDownloading.toggle()
                    }, label: {
                        Image(systemName: "arrow.down.circle")
                    })
                })
                .sheet(isPresented: $presentingVideoDownloading, content: {
                    VideoDownloadingView()
                })
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
