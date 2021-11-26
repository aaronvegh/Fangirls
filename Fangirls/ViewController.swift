//
//  ViewController.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import Cocoa

class TaskManager {
    static let shared = TaskManager()

    var inProgressTasks: [InProgressTask] = []
}

class ViewController: NSViewController {

    // MARK: - Properties
    // MARK:

    @IBOutlet weak var statusField: NSTextField!
    @IBOutlet weak var videoURLField: NSTextField!
    @IBOutlet weak var downloadTableView: NSTableView!
    @IBOutlet weak var downloadLocationButton: NSButton!
    @IBOutlet weak var downloadLocationField: NSTextField!
    @IBOutlet weak var downloadLocationRevealButton: NSButton!
    @IBOutlet weak var maskView: NSView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.videoURLField.becomeFirstResponder()

        setDownloadLocationField()

        self.progressIndicator.startAnimation(nil)
        self.maskView.wantsLayer = true
        self.maskView.layer?.backgroundColor = NSColor(deviceWhite: 0.1, alpha: 0.5).cgColor
        getYTDLVersion()
//        updateYoutubeDL(sender: self)
    }

    override func viewDidAppear() {
        self.sizeWindow()
    }


    // MARK: - IBActions
    // MARK:
    
    private func getYTDLVersion() {
        YoutubeDL.getYTDLVersion { (type) in
            guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
            switch type {
            case .success(let value):
                if let versionString = value.first?["Version"] {
                    appDelegate.updateMenuItem.title = "Update yt-dlp (\(versionString))..."
                }
            case .failure:
                appDelegate.updateMenuItem.title = "Update yt-dlp..."
            }
        }
    }
    
    @IBAction func updateYoutubeDL(sender: AnyObject) {
        YoutubeDL.updateVersion() { returnType in
            switch returnType {
            case .success(let data):
                self.getYTDLVersion()
                print("Result: \(data)")
            default:
                print("failed to update")
            }
        }
    }

    @IBAction func getVideo(sender: AnyObject) {
        if let videoURL = URL(string: self.videoURLField.stringValue) {
            self.videoURLField.stringValue = ""
            
            self.maskView.isHidden = false

            let task = InProgressTask(identifier: videoURL.absoluteString)
            TaskManager.shared.inProgressTasks.append(task)
            downloadTableView.reloadData()
            
            let youtubeDL = YoutubeDL(task: task)

            self.sizeWindow()

            youtubeDL.getVideoData { success in
                DispatchQueue.main.async {
                    guard let task = TaskManager.shared.inProgressTasks.first(where: { $0.identifier == videoURL.absoluteString }),
                          task.process != nil else {
                              self.downloadTableView.reloadData()
                              return
                          }

                    if let index = TaskManager.shared.inProgressTasks.firstIndex(where:  { $0.identifier == videoURL.absoluteString }),
                       let progressCell = self.downloadTableView.view(atColumn: 1, row: index, makeIfNecessary: true) as? ProgressTableCellView {
                        progressCell.task = task

                        if let imageCell = self.downloadTableView.view(atColumn: 0, row: index, makeIfNecessary: true) as? ImageTableCellView {
                            self.setThumbnailImage(for: task, in: imageCell)
                        }
                    }
                    self.maskView.isHidden = true
                }
            }
        }
    }

    @objc private func resetVideoStatus() {
        self.statusField.stringValue = ""
    }

    @IBAction func chooseDownloadLocation(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginSheetModal(for: self.view.window!) { (button) in
            if button == NSApplication.ModalResponse.OK {
                let directoryURL = openPanel.urls[0]
                Settings.shared.downloadLocation = directoryURL
                self.setDownloadLocationField()
            }
        }
    }

    @IBAction func revealDownloadLocation(sender: NSButton) {
        if NSWorkspace().open(Settings.shared.downloadLocation) == false {
            self.statusField.stringValue = "File location not found!"
        }
    }

    // MARK: - Private Methods
    // MARK:


    private func sizeWindow() {
        DispatchQueue.main.async {
            let animate = TaskManager.shared.inProgressTasks.count > 0
            let tableHeight = 110 * TaskManager.shared.inProgressTasks.count
            let newHeight = CGFloat(125 + tableHeight)

            if let window = self.view.window {
                let thisHeight = newHeight - window.frame.size.height
                let newY = window.frame.origin.y - thisHeight
                let newFrame = NSRect(x: window.frame.origin.x, y: newY, width: window.frame.size.width, height: newHeight)
                window.setFrame(newFrame, display: true, animate: animate)
            }
        }
    }

    private func setDownloadLocationField() {
        self.downloadLocationField.stringValue = "Download to \(Settings.shared.downloadLocation.path)"
    }
}

// MARK: - NSTableView Delegates
// MARK:

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else { return nil }
        guard let task = TaskManager.shared.inProgressTasks[safe: row] else { return nil }

        if identifier.rawValue == "imageCell" {
            if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? ImageTableCellView {
                self.setThumbnailImage(for: task, in: cell)
                return cell
            }
        } else if identifier.rawValue == "progressCell" {
            if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? ProgressTableCellView {
                cell.task = task
                return cell
            }
        }

    return nil

    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return TaskManager.shared.inProgressTasks.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if edge == .trailing {
            let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete") { action, index in
                if let task = TaskManager.shared.inProgressTasks[safe: index] {
                    task.process?.terminate()

                    TaskManager.shared.inProgressTasks.remove(at: index)
                }
                tableView.reloadData()
                self.sizeWindow()
            }
            return [deleteAction]
        } else {
            return []
        }
    }

    func setThumbnailImage(for task: InProgressTask, in cell: ImageTableCellView) {
        guard let thumbURL = task.thumbnailURL else { return }
        let imageSize = CGSize(width: 95, height: 80)
        if let image = NSImage(contentsOfFile: thumbURL.path) {
            let resizedImage = resizeImage(image, size: imageSize)
            cell.imageView?.image = resizedImage
        }
    }

    func resizeImage(_ sourceImage: NSImage, size: CGSize) -> NSImage {
        let targetFrame = CGRect(origin: CGPoint.zero, size: size);
        let targetImage = NSImage.init(size: size)
        let sourceSize = sourceImage.size
        let ratioH = size.height / sourceSize.height;
        let ratioW = size.width / sourceSize.width;

        var cropRect = CGRect.zero;
        if (ratioH >= ratioW) {
            cropRect.size.width = floor (size.width / ratioH);
            cropRect.size.height = sourceSize.height;
        } else {
            cropRect.size.width = sourceSize.width;
            cropRect.size.height = floor(size.height / ratioW);
        }

        cropRect.origin.x = floor( (sourceSize.width - cropRect.size.width)/2 );
        cropRect.origin.y = floor( (sourceSize.height - cropRect.size.height)/2 );
        targetImage.lockFocus()
        sourceImage.draw(in: targetFrame, from: cropRect, operation: .copy, fraction: 1.0, respectFlipped: true, hints: nil )


        targetImage.unlockFocus()
        return targetImage;
    }
}

