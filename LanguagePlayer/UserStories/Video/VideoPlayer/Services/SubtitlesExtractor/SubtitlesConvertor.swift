//
//  SubtitlesConvertor.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation

protocol SubtitlesConvertor {
    func prepareParts(from filePath: URL)
    
    func getSubtitle(for time: Milliseconds) -> SubtitlePart?
    func getPreviousSubtitle(current time: Milliseconds) -> SubtitlePart?
    func getNextSubtitle(current time: Milliseconds) -> SubtitlePart?
}

struct SubtitlePart {
    let number: Int
    let fromTime: Milliseconds
    let toTime: Milliseconds
    let text: String
}

struct DoubleSubtitles: Equatable {
    let source: SubtitlePart?
    let target: SubtitlePart?
    
    static func == (lhs: DoubleSubtitles, rhs: DoubleSubtitles) -> Bool {
        lhs.source?.number == rhs.source?.number &&
            lhs.target?.number == rhs.target?.number
    }
}
