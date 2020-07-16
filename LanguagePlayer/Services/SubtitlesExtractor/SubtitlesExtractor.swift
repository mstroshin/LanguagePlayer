//
//  SubtitlesExtractor.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 16.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation

protocol SubtitlesExtractor {
    func getSubtitle(for timeInMilliseconds: TimeInterval) -> String?
}
