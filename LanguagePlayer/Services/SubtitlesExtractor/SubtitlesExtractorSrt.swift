//
//  SubtitlesExtractorSrt.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation

class SubtitlesExtractorSrt: SubtitlesExtractor {
    private let filePath: URL
    private var parts = [SubtitlePart]()
    
    init(with filePath: URL) {
        if filePath.pathExtension != "srt" {
            fatalError("Subtitle file must have srt format")
        }
        
        self.filePath = filePath
        self.prepareSubtitles()
    }
    
    private func prepareSubtitles() {
        do {
            let subtitles = try String(contentsOf: self.filePath)
            self.parts = self.parse(subtitles).sorted(by: { lhs, rhs -> Bool in
                lhs.fromTime < rhs.fromTime
            })
        } catch {
            fatalError("Doesn't read subtitle file \(self.filePath)")
        }
    }
    
    private func parse(_ subtitles: String) -> [SubtitlePart] {
        var result = [SubtitlePart]()
        let subtitles = subtitles.replacingOccurrences(of: "\r", with: "")
        
        let parts = subtitles.components(separatedBy: "\n\n")
        for part in parts {
            if part.isEmpty { continue }
            
            let lines = part.components(separatedBy: "\n")
            guard let number = Int(lines[0]) else {
                fatalError("Doesn't parse subtitle file \(self.filePath)")
            }
            
            let timeRange = lines[1]
            let times = timeRange.components(separatedBy: " --> ")
            
            let fromTime = self.parse(timeString: times[0])
            let toTime = self.parse(timeString: times[1])
            
            var text = ""
            for i in 2 ..< lines.count {
                text.append(lines[i])
                text.append("\n")
            }
            //Remove last \n
            text.removeLast(2)
            
            result.append(
                SubtitlePart(number: number, fromTime: fromTime, toTime: toTime, text: text)
            )
        }
        
        return result
    }
    
    private func parse(timeString: String) -> Milliseconds {
        let timeParts = timeString.components(separatedBy: ":")
        let secondsAndMilliseconds = timeParts[2].components(separatedBy: ",")
        
        let hours = Milliseconds(timeParts[0])!
        let minutes = Milliseconds(timeParts[1])!
        let seconds = Milliseconds(secondsAndMilliseconds[0])!
        let milliseconds = Milliseconds(secondsAndMilliseconds[1])!
        
        return hours * 3600000 + minutes * 60000 + seconds * 1000 + milliseconds
    }
    
    func getSubtitle(for time: Milliseconds) -> SubtitlePart? {
        self.parts.first { time >= $0.fromTime && time <= $0.toTime }
    }
    
    func getPreviousSubtitle(current time: Milliseconds) -> SubtitlePart? {
        if let currentSubtitle = self.getSubtitle(for: time) {
            return self.parts.first { $0.number == currentSubtitle.number - 1 }
        }
        
        return self.parts.reversed().first { $0.fromTime < time }
    }
    
    func getNextSubtitle(current time: Milliseconds) -> SubtitlePart? {
        if let currentSubtitle = self.getSubtitle(for: time) {
            return self.parts.first { $0.number == currentSubtitle.number + 1 }
        }
        
        return self.parts.first { time < $0.fromTime }
    }
    
}
