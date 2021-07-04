//
//  Extensions.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 04.07.2021.
//

import Foundation

extension FileManager {

    static func rename(file path: URL, to name: String) -> URL? {
        let newPath = path.deletingLastPathComponent().appendingPathComponent(name, isDirectory: false)

        do {
            try FileManager.default.moveItem(at: path, to: newPath)
            return newPath
        } catch {
            return nil
        }
    }

    @discardableResult
    static func clearTmpDirectory() -> Bool {
        let fm = FileManager.default

        do {
            let tmpDirURL = fm.temporaryDirectory
            let tmpDirectory = try fm.contentsOfDirectory(atPath: tmpDirURL.path)

            for file in tmpDirectory {
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try fm.removeItem(atPath: fileUrl.path)
            }

            return true
        } catch {
            return false
        }
    }

    static func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let path = documentDirectoryPath.first else { return nil }

        let fileUrl = URL(fileURLWithPath: path)
        do {
            let resourceValues = try fileUrl.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            let freeSpace = resourceValues.volumeAvailableCapacityForImportantUsage
            return freeSpace
        } catch {
            return nil
        }
    }

}
