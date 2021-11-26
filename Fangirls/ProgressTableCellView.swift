//
//  ProgressTableCellView.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import AppKit

class ProgressTableCellView: NSTableCellView {

    @IBOutlet weak var videoTitle: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressIndictor: NSProgressIndicator!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.task = nil
        self.progressIndictor.isHidden = false
    }

    var task: InProgressTask? {
        didSet {
            guard
                  let progressIndicator = self.progressIndictor,
                  let task = task,
                  task.process != nil else { return }
            videoTitle.stringValue = task.title ?? "No title"
            progressLabel.stringValue = "\(task.percent ?? "0%") of \(task.totalSize ?? "0B") at \(task.speed ?? "0bps"). ETA \(task.timeRemaining ?? "00")"
            guard
                let percent = task.percent?.replacingOccurrences(of: "%", with: ""),
                let unitCount = Double(percent) else { return }
            progressIndicator.doubleValue = unitCount

            if unitCount == 100 {
                finishDownload()
                progressLabel.stringValue = "Download complete."
            }
        }
    }

    @IBAction func deleteDownload(sender: NSButton) {
        guard let task = TaskManager.shared.inProgressTasks.first(where: { $0.identifier == task?.identifier }) else { return }
        task.process?.terminate()
        task.process = nil
        progressLabel.stringValue = "Download cancelled."
        finishDownload()
    }

    private func finishDownload() {
        if let progressIndicator = progressIndictor {
            progressIndicator.isHidden = true
        }
        self.task = nil
    }
}
