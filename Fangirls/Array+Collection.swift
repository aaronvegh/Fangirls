//
//  Array+Collection.swift
//  Fangirls
//
//  Created by Aaron Vegh on 2021-11-10.
//  Copyright © 2021 Aaron Vegh. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    var isNotEmpty: Bool {
        return !isEmpty
    }
}
