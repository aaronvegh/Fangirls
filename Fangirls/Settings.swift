//
//  Settings.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2016-09-02.
//  Copyright © 2016 Aaron Vegh. All rights reserved.
//

import Foundation

struct Settings {
    static var shared = Settings()

    var downloadLocation: URL {
        get {
            let defaults = UserDefaults.standard
            if let path = defaults.url(forKey: "com.innoveghtive.fangirls.downloadURL") {
                return path
            } else {
                return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0])
            }
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "com.innoveghtive.fangirls.downloadURL")
        }
    }
}
