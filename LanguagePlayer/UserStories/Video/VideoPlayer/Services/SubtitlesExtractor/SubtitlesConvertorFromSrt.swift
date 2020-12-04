//
//  SubtitlesConvertorFromSrt.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation

class SubtitlesConvertorFromSrt: SubtitlesConvertor {
    private var filePath: URL!
    private var parts = [SubtitlePart]()
    
    func prepareParts(from filePath: URL) {
        self.parts.removeAll()
        
        if filePath.pathExtension != "srt" {
            fatalError("Subtitle file must have srt format")
        }
        
        self.filePath = filePath
        self.prepareSubtitles()
    }
    
    private func prepareSubtitles() {
        do {
            let subtitles = try String(contentsOf: self.filePath)
//            self.parts = self.parse(subtitles).sorted(by: { lhs, rhs -> Bool in
//                lhs.fromTime < rhs.fromTime
//            })
            self.parts = try! self.parseSRTSub(subtitles).sorted(by: { lhs, rhs -> Bool in
                lhs.fromTime < rhs.fromTime
            })
        } catch {
            fatalError("Doesn't read subtitle file \(self.filePath)\n Error: \(error)")
        }
    }
    
    private func parse(_ subtitles: String) -> [SubtitlePart] {
        var result = [SubtitlePart]()
        let subtitles = subtitles.replacingOccurrences(of: "\r", with: "")
        
        let parts = subtitles.components(separatedBy: "\n\n")
        for part in parts {
            if part.isEmpty { continue }
            
            let lines = part.components(separatedBy: "\n").filter { !$0.isEmpty }
            if lines.count < 3 { continue }
            
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
            text.removeLast(1)
            text = self.removeFormatting(from: text)
            
            result.append(
                SubtitlePart(number: number, fromTime: fromTime, toTime: toTime, text: text)
            )
        }
        
        return result
    }
    
    func parseSRTSub(_ rawSub: String) throws -> [SubtitlePart] {
            var allTitles = [SubtitlePart]()
            var components = rawSub.components(separatedBy: "\r\n\r\n")
            
            // Fall back to \n\n separation
            if components.count == 1 {
                components = rawSub.components(separatedBy: "\n\n")
            }
            
            for component in components {
                if component.isEmpty {
                    continue
                }
                
                let scanner = Scanner(string: component)
                
                let indexResult = scanner.scanInt()
                let startResult = scanner.scanUpToCharacters(from: .whitespaces)
                
                let _ = scanner.scanUpToString("> ") != nil
                scanner.currentIndex = scanner.string.index(scanner.currentIndex, offsetBy: 2, limitedBy: scanner.string.endIndex) ?? scanner.currentIndex
                
                let endResult = scanner.scanUpToCharacters(from: .newlines)
                scanner.currentIndex = scanner.string.index(scanner.currentIndex, offsetBy: 1, limitedBy: scanner.string.endIndex) ?? scanner.currentIndex
                
                var textLines = [String]()
                
                // Iterate over text lines
                while scanner.isAtEnd == false {
                    if let textResult = scanner.scanUpToCharacters(from: .newlines) {
                        textLines.append(removeFormatting(from: textResult))
                    } else {
                        fatalError("123")
                    }
                }
                if textLines.isEmpty { continue }
                
                let startTimeInterval = parse(timeString: startResult!)
                let endTimeInterval = parse(timeString: endResult!)
                
                allTitles.append(
                    SubtitlePart(number: indexResult!, fromTime: startTimeInterval, toTime: endTimeInterval, text: textLines.joined())
                )
            }
            
            return allTitles
        }
    
    private func removeFormatting(from text: String) -> String {
        text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "{[^>]+}", with: "", options: .regularExpression, range: nil)
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
