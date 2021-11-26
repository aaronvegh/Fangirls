//
//  ImageTableCellView.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-08-31.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import AppKit

class ImageTableCellView: NSTableCellView {

    override func awakeFromNib() {
        guard let myImageView = self.imageView else { return }
        myImageView.wantsLayer = true
        myImageView.layer?.backgroundColor = CGColor.white
        myImageView.layer?.borderColor = CGColor.black
        myImageView.layer?.borderWidth = 2
        myImageView.layer?.cornerRadius = 5

        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        shadow.shadowBlurRadius = 2
        myImageView.shadow = shadow
    }
}
