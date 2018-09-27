//
//  ViewController.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-28.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import Cocoa

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
    }

    override func viewDidAppear() {
        self.sizeWindow()
    }


    // MARK: - IBActions
    // MARK:

    @IBAction func getVideo(sender: AnyObject) {
        if let videoURL = URL(string: self.videoURLField.stringValue) {
            self.videoURLField.stringValue = ""
            
            self.maskView.isHidden = false

            YoutubeDL.getVideoData(url: videoURL.absoluteString, completion: { (returnType) in

                DispatchQueue.main.async {
                    self.maskView.isHidden = true
                }

                switch returnType {
                case .Success(let data):

                    DispatchQueue.main.async {
                        self.statusField.stringValue = "\(data.count) video\(data.count > 1 ? "s" : "") found"
                    }

                    for dict in data {

                        let progress = Progress(totalUnitCount: 100)
                        
                        let newVideo = Video()
                        newVideo.title = dict["title"] ?? ""
                        newVideo.downloadURL = dict["url"] ?? ""
                        newVideo.thumbnailURL = dict["thumbnailURL"] ?? ""
                        newVideo.downloadProgress = progress
                        newVideo.filename = dict["filename"] ?? ""

                        let downloader = Downloader()
                        downloader.taskTrackable = self
                        downloader.fetch(video: newVideo)

                        let newTask = VideoDownloadTask(video: newVideo, downloader: downloader)
                        Downloader.shared.downloadTasks.append(newTask)
                        DispatchQueue.main.async {
                            self.downloadTableView.reloadData()
                        }
                    }

                    self.sizeWindow()
                case .Failure:
                    DispatchQueue.main.async {
                        self.statusField.stringValue = "No videos found!"
                    }
                    break
                }
            })
        }
    }

    @IBAction func chooseDownloadLocation(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginSheetModal(for: self.view.window!) { (button) in
            if button.rawValue == NSFileHandlingPanelOKButton {
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
            let animate = Downloader.shared.downloadTasks.count > 0
            let tableHeight = 100 * Downloader.shared.downloadTasks.count
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


// MARK: - TaskTrackable
// MARK:

extension ViewController: TaskTrackable {
    func didUpdateTasks() {
        self.downloadTableView.reloadData()
    }
}

// MARK: - NSTableView Delegates
// MARK:

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else { return nil }
        guard let video = Downloader.shared.downloadTasks[row].video else { return nil }

        if identifier.rawValue == "imageCell" {
            if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView {
                guard let thumbURL = URL(string: video.thumbnailURL) else { return nil }
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.downloadTask(with: thumbURL, completionHandler: { (location, response, error) in
                    guard let location = location else { return }
                    do {
                        let data = try Data(contentsOf: location, options: [])
                        if let image = NSImage(data: data) {
                            DispatchQueue.main.async {
                                cell.imageView?.image = image
                            }
                        }
                    } catch {
                        return
                    }
                })
                task.resume()

                return cell
            }
        } else if identifier.rawValue == "progressCell" {
            if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? ProgressTableCellView {
                cell.video = video
                cell.videoTitle.stringValue = video.title
                return cell
            }
        }

    return nil

    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return Downloader.shared.downloadTasks.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
}

