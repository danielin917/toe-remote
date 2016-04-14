//
//  Helpers.swift
//  toe-remote
//
//  Created by Nick Terrell on 4/14/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

import Foundation
import UIKit

func makeAccessible(label: UILabel?) {
    label?.adjustsFontSizeToFitWidth = true
    label?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
}

func makeAccessible(button: UIButton?) {
    button?.titleLabel?.adjustsFontSizeToFitWidth = true
    button?.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
}

func dropNull(bytes: Slice<UnsafeBufferPointer<UInt8>>) -> Slice<UnsafeBufferPointer<UInt8>> {
    let splits = bytes.split(0)
    if splits.count > 0 {
        return splits[0]
    }
    return bytes
}