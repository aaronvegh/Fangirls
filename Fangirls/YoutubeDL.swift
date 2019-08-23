//
//  YoutubeDL.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import AppKit

typealias KeyValueType = [[String: String]]

enum ReturnType {
    case Success(KeyValueType)
    case Failure
}

struct YoutubeDL {

    static var scriptPath: String {
        return Bundle.main.path(forResource: "youtube-dl", ofType: nil)!
    }
    
    static func getVideoData(url: String, completion: @escaping ((ReturnType) -> Void)) {
        let task = Process()
        task.launchPath = YoutubeDL.scriptPath
        
        task.arguments = ["--verbose", "-eg", "--get-thumbnail", "--get-filename", "--no-playlist", "-f mp4", "\(url)"]
        task.standardOutput = Pipe()
        task.launch()
        task.terminationHandler = { (process: Process) in
            guard let outputPipe = task.standardOutput as? Pipe else { return }
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            
            guard let output = String(data: outputData, encoding: .utf8) else { return }
            let bits = output.components(separatedBy: "\n")
            
            if bits.count > 4 {
                var finalBits = bits.splitBy(subSize: 4)
                finalBits.removeLast()
                let completionData = finalBits.map({ (video) in
                    return ["title": video[0], "url": video[1], "filename": video[3], "thumbnailURL": video[2]]
                })
                completion(.Success(completionData))
            } else {
                completion(.Failure)
            }
            
        }
    }
    
    static func getYTDLVersion(completion: @escaping ((ReturnType) -> Void)) {
        let task = Process()
        task.launchPath = YoutubeDL.scriptPath
        
        task.arguments = ["--version"]
        task.standardOutput = Pipe()
        task.launch()
        task.terminationHandler = { (process: Process) in
            guard let outputPipe = task.standardOutput as? Pipe else { completion(.Failure); return }
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            
            guard let output = String(data: outputData, encoding: .utf8) else { completion(.Failure); return }
            let dict = ["Version": output]
            
            guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.updateMenuItem.title = "Update YoutubeDL (\(output))..."
            
            return completion(.Success([dict]))
        }
    }

    static func updateVersion(completion: @escaping ((ReturnType) -> Void)) {
        let task = Process()
        task.launchPath = YoutubeDL.scriptPath
        task.arguments = ["-U"]
        task.standardOutput = Pipe()

        task.launch()
        task.terminationHandler = { (process: Process) in
            guard let outputPipe = task.standardOutput as? Pipe else { return }
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

            guard let output = String(data: outputData, encoding: .utf8) else { return }
            let result = ["result": output]
            completion(.Success([result]))
        }
    }
}

extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: subSize).map { startIndex in
            if let endIndex = self.index(startIndex, offsetBy: subSize, limitedBy: self.count) {
            //let endIndex = startIndex.advancedBy(subSize, limit: self.count)
                return Array(self[startIndex ..< endIndex])
            }
            return Array()
        }
    }
}
