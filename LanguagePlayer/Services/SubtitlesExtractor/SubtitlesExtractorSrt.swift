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
            
            guard let fromTime = self.parseToMilliseconds(timeString: times[0]),
                let toTime = self.parseToMilliseconds(timeString: times[1]) else {
                fatalError("Doesn't parse subtitle file \(self.filePath)")
            }
            
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
    
    private func parseToMilliseconds(timeString: String) -> TimeInterval? {
        let timeParts = timeString.components(separatedBy: ":")
        let secondsAndMilliseconds = timeParts[2].components(separatedBy: ",")
        
        let hours = TimeInterval(timeParts[0])!
        let minutes = TimeInterval(timeParts[1])!
        let seconds = TimeInterval(secondsAndMilliseconds[0])!
        let milliseconds = TimeInterval(secondsAndMilliseconds[1])!
        
        return hours * 3600000 + minutes * 60000 + seconds * 1000 + milliseconds
    }
    
    func getSubtitle(for timeInMilliseconds: TimeInterval) -> SubtitlePart? {
        let r = self.parts.first { timeInMilliseconds >= $0.fromTime && timeInMilliseconds <= $0.toTime }
        return r
    }
    
    func getPreviousSubtitle(current timeInMilliseconds: TimeInterval) -> SubtitlePart? {
        if let currentSubtitle = self.getSubtitle(for: timeInMilliseconds) {
            return self.parts.first { $0.number == currentSubtitle.number - 1 }
        }
        
        return self.parts.reversed().first { $0.fromTime < timeInMilliseconds }
    }
    
    func getNextSubtitle(current timeInMilliseconds: TimeInterval) -> SubtitlePart? {
//        print("Next time \(timeInMilliseconds)")
        
        if let currentSubtitle = self.getSubtitle(for: timeInMilliseconds) {
            let r = self.parts.first { $0.number == currentSubtitle.number + 1 }
//            print("Next \(String(describing: r?.number))")
            
            return r
        }
        
        let r = self.parts.first { timeInMilliseconds < $0.fromTime }
//        print("Next 2 \(String(describing: r?.number))")

        return r
    }
    
}
