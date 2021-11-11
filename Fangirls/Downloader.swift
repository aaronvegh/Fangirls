//
//  Downloader.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import Foundation

protocol Downloadable {
    func downloadDidStart()
    func downloadUpdatedProgress(percentComplete: Float)
    func downloadDidComplete(fileLocation: URL?, error: Error?)
}

protocol TaskTrackable {
    func didUpdateTasks()
}

struct VideoDownloadTask {
    var video: Video?
    var downloader: Downloader?
    var task: URLSessionDownloadTask?
}

extension VideoDownloadTask: Equatable {}

func ==(lhs: VideoDownloadTask, rhs: VideoDownloadTask) -> Bool {
    return lhs.video?.downloadURL == rhs.video?.downloadURL
}


class Downloader: NSObject, URLSessionDownloadDelegate {
    static var shared = Downloader()
    var downloadTasks = [VideoDownloadTask]() {
        didSet {
            guard let tracker = self.taskTrackable else { return }
            tracker.didUpdateTasks()
        }
    }

    var downloadedData: Data?
    var video: Video?
    var taskTrackable: TaskTrackable?
    var downloadSessionTask: URLSessionDownloadTask?

    func fetch(video: Video) {
        self.video = video
        let defaultConfig = URLSessionConfiguration.default
        let delegateQueue = OperationQueue()
        let session = URLSession(configuration: defaultConfig, delegate: self, delegateQueue: delegateQueue)
        downloadSessionTask = session.downloadTask(with: URL(string: video.downloadURL)!)
        downloadSessionTask?.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        let percentComplete = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100

        if Progress.current() != video?.downloadProgress {
            video?.downloadProgress?.becomeCurrent(withPendingUnitCount: 1)
        }

        video?.downloadUpdatedProgress(percentComplete: percentComplete)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        video?.downloadDidComplete(fileLocation: location, error: nil)
    }
}
