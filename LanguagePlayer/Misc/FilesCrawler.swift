//
//  FilesCrawler.swift
//  LanguagePlayer
//
//  Created by Maxim on 21.12.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation

var numberOfDir = 0
var numberOfFile = 0

func fileCrawl(_ url : URL, _ prefix: String = "", _ shit: Bool = true){
    if shit {
        print(prefix + url.lastPathComponent)
    }
    let fileManager = FileManager.default
    var newPrefix = prefix
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        // process files
        for files in fileURLs{
            if let lastFile = fileURLs.last{
                if lastFile == files {
                    newPrefix = prefix + " └─ "
                } else{
                    newPrefix = prefix + " ├─ "
                }
            }
            print(newPrefix + files.lastPathComponent)
            if files.hasDirectoryPath{
                numberOfDir += 1
                if let lastFile = fileURLs.last{
                    if lastFile == files {
                        newPrefix = prefix + "    "
                    } else {
                        newPrefix = prefix + " │  "
                    }
                }
                fileCrawl(files, newPrefix, false)
            }else{
                numberOfFile += 1
            }
        }
        
    } catch {
        print("Error while enumerating files \(url): \(error.localizedDescription)")
    }
}
