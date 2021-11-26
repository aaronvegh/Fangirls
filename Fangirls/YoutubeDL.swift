//
//  YoutubeDL.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import AppKit

class InProgressTask: NSObject {
    var identifier: String
    var thumbnailURL: URL?
    var title: String?
    var timeRemaining: String?
    var percent: String?
    var speed: String?
    var totalSize: String?

    var process: Process?

    init(identifier: String) {
        self.identifier = identifier
        super.init()
    }
}

typealias KeyValueType = [[String: String]]

enum ReturnType {
    case success(KeyValueType)
    case failure
}

class YoutubeDL: NSObject {

    static var scriptPath: String {
        return Bundle.main.path(forResource: "yt-dlp", ofType: nil)!
    }

    var inProgressTask: InProgressTask

    var progressObserver: Any?

    init(task: InProgressTask) {
        self.inProgressTask = task
    }
    
    func getVideoData(completion: @escaping ((Bool) -> Void)) {
        let task = Process()
        task.launchPath = YoutubeDL.scriptPath
        
        task.arguments = ["--verbose", "--write-thumbnail", "-P", Settings.shared.downloadLocation.path, "--no-playlist", "-f mp4", "\(inProgressTask.identifier)"]
        let pipe = Pipe()
        task.standardOutput = pipe

        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        progressObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: outHandle, queue: nil) { _ in
            let data = outHandle.availableData

            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) {

                    if str.contains("Writing video thumbnail") {
                        if let match = self.matches(for: "to: (.*$)", in : str).first {
                            let thumbPath = match.replacingOccurrences(of: "to: ", with: "")
                            if let appSupportPath = self.applicationSupportPath {
                                let src = URL(fileURLWithPath: thumbPath)
                                let dest = URL(fileURLWithPath: appSupportPath).appendingPathComponent(src.lastPathComponent)
                                try? FileManager.default.moveItem(at: src, to: dest)
                                self.inProgressTask.thumbnailURL = dest
                            }
                        }
                    }

                    if str.contains("Destination: ") {
                        if let match = self.matches(for: "\\[download\\] Destination: (.*)", in: str).first {
                            let destPath = match.replacingOccurrences(of: "[download] Destination: ", with: "")
                            let destURL = URL(fileURLWithPath: destPath)
                            self.inProgressTask.title = destURL.deletingPathExtension().lastPathComponent
                        }
                    }

                    if str.contains("ETA") {
                        let pattern = #"""
                        (?xi)
                        \[download\]\s+
                        (?<percent>
                            \d{1,3}\.\d%)
                        \s+of\s+
                        (?<totalSize>
                            ~{0,1}\d{1,}\.\d{1,}\w*)
                        \s+at\s+
                        (?<speed>
                            \d{1,}\.\d{1,}[\w\/]*)
                        \s+ETA\s+
                        (?<timeRemaining>
                            [:\d]+)
                        """#
                        do {
                            let regex = try NSRegularExpression(pattern: pattern, options: [])
                            let nsrange = NSRange(str.startIndex..<str.endIndex, in: str)
                            if let match = regex.firstMatch(in: str,
                                                            options: [],
                                                            range: nsrange) {
                                for component in ["percent", "totalSize", "speed", "timeRemaining"] {
                                    let nsrange = match.range(withName: component)
                                    if nsrange.location != NSNotFound,
                                        let range = Range(nsrange, in: str) {
                                        switch component {
                                        case "percent":
                                            self.inProgressTask.percent = "\(str[range])"
                                        case "totalSize":
                                            self.inProgressTask.totalSize = "\(str[range])"
                                        case "speed":
                                            self.inProgressTask.speed = "\(str[range])"
                                        case "timeRemaining":
                                            self.inProgressTask.timeRemaining = "\(str[range])"
                                        default: break
                                        }
                                    }
                                }
                            }
                        } catch (let error) {
                            print("error: \(error)")
                        }
                    }

                    completion(true)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                // That means we've reached the end of the input.
                guard let observer = self.progressObserver else { return }
                NotificationCenter.default.removeObserver(observer)
            }
        }

        self.inProgressTask.process = task

        task.launch()
    }
    
    static func getYTDLVersion(completion: @escaping ((ReturnType) -> Void)) {
        let task = Process()
        task.launchPath = YoutubeDL.scriptPath
        
        task.arguments = ["--version"]
        task.standardOutput = Pipe()
        task.launch()
        task.terminationHandler = { (process: Process) in
            DispatchQueue.main.async {
                guard let outputPipe = task.standardOutput as? Pipe else { completion(.failure); return }
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

                guard let output = String(data: outputData, encoding: .utf8) else { completion(.failure); return }
                let dict = ["Version": output]

                guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
                appDelegate.updateMenuItem.title = "Update yt-dlp (\(output))..."

                return completion(.success([dict]))
            }
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
            DispatchQueue.main.async {
                completion(.success([result]))
            }
        }
    }

    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    private var applicationSupportPath: String? {
        guard let appSupportDirectoryPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first else { return nil }
        let targetPath = "\(appSupportDirectoryPath)/Fangirls"
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: targetPath, isDirectory: &isDir)
        if !isDir.boolValue {
            try? FileManager.default.createDirectory(atPath: targetPath, withIntermediateDirectories: false, attributes: nil)
        }
        return targetPath
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
