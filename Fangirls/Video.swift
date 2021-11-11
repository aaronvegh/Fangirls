//
//  Video.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import Foundation

class Video {
    var title: String = ""
    var downloadURL: String = ""
    var thumbnailURL: String = ""
    var filename: String = ""
    var downloadProgress: Progress?
}

extension Video: Equatable {
    static func ==(lhs: Video, rhs: Video) -> Bool {
        return lhs.downloadURL == rhs.downloadURL
    }
}

extension Video: Downloadable {
    func downloadDidStart() {}

    func downloadUpdatedProgress(percentComplete: Float) {
        downloadProgress?.completedUnitCount = Int64(percentComplete)
    }

    func downloadDidComplete(fileLocation: URL?, error: Error?) {
        var spotURL = Settings.shared.downloadLocation
        spotURL.appendPathComponent(filename)
        do {
            try FileManager.default.moveItem(at: fileLocation!, to: spotURL)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
}
