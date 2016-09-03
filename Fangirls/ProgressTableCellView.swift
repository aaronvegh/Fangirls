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
    @IBOutlet weak var progressLabelTopConstraint: NSLayoutConstraint!
    var video: Video? {
        didSet {
            if self.progressIndictor != nil {
                video?.downloadProgress?.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "fractionCompleted" && self.progressIndictor != nil {
            guard let unitCount = video?.downloadProgress?.completedUnitCount else { return }
            DispatchQueue.main.async {
                self.progressIndictor.doubleValue = Double(unitCount)
                self.progressLabel.stringValue = (self.video?.downloadProgress?.localizedDescription)!
            }

            if unitCount == 100 {
                video?.downloadProgress?.removeObserver(self, forKeyPath: "fractionCompleted")
                DispatchQueue.main.async {
                    self.progressIndictor.removeFromSuperview()
                    self.progressLabelTopConstraint.constant = 8
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}
