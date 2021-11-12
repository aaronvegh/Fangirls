//
//  Downloader.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import Foundation
import AVKit

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
    var task: URLSessionTask?
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

    let configuration = URLSessionConfiguration.background(withIdentifier: "downloadIdentifier")

    var downloadedData: Data?
    var video: Video?
    var taskTrackable: TaskTrackable?
    var downloadSessionTask: URLSessionTask?

    func fetch(video: Video) {
        self.video = video
        let delegateQueue = OperationQueue()
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: delegateQueue)
        downloadSessionTask = session.downloadTask(with: URL(string: video.downloadURL)!)
        downloadSessionTask?.resume()
    }

    func fetchStream(video: Video) {
        self.video = video

            // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
        let downloadSession = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: OperationQueue.main)

        guard let url = URL(string: video.downloadURL) else { return }
        let asset = AVURLAsset(url: url)

        // Create new AVAssetDownloadTask for the desired asset
        downloadSessionTask = downloadSession.makeAssetDownloadTask(
            asset: asset,
            assetTitle: video.title,
            assetArtworkData: nil,
            options: nil)

        // Start task and begin download
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

extension Downloader: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentComplete: Float = 0.0
        // Iterate through the loaded time ranges
        for value in loadedTimeRanges {
            // Unwrap the CMTimeRange from the NSValue
            let loadedTimeRange = value.timeRangeValue
            // Calculate the percentage of the total expected asset duration
            percentComplete += Float(loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds)
        }
        percentComplete *= 100
        video?.downloadUpdatedProgress(percentComplete: percentComplete)
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        video?.downloadDidComplete(fileLocation: location, error: nil)
    }
}
