//
//  ControllerData.swift
//  controller-maker
//
//  Created by Nick Terrell on 4/3/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

import Cocoa


func toUInt8(value: Int32?) -> UInt8? {
    if value != nil && (0 <= value!) && (value! < 256) {
        return UInt8(value!)
    }
    return nil
}

func toUInt16(value: Int32?) -> UInt16? {
    if value != nil && (0 <= value!) && (value! < 65536) {
        return UInt16(value!)
    }
    return nil
}

class ButtonData: NSObject {
    var x: UInt8?
    var y: UInt8?
    var width: UInt8?
    var height: UInt8?
    
    var label: String?
    var imageURL: NSURL?
    
    var action: UInt16?
    
    init(label: String) {
        self.label = label
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        x = toUInt8(decoder.decodeInt32ForKey("x"))
        y = toUInt8(decoder.decodeInt32ForKey("y"))
        width = toUInt8(decoder.decodeInt32ForKey("width"))
        height = toUInt8(decoder.decodeInt32ForKey("height"))
        action = toUInt16(decoder.decodeInt32ForKey("action"))
        label = decoder.decodeObjectForKey("label") as? String
        imageURL = decoder.decodeObjectForKey("imageURL") as? NSURL
    }
    
    func encodeWithCoder(coder: NSCoder) {
        if x != nil {
            coder.encodeInt32(Int32(x!), forKey: "x")
        }
        if y != nil {
            coder.encodeInt32(Int32(y!), forKey: "y")
        }
        if width != nil {
            coder.encodeInt32(Int32(width!), forKey: "width")
        }
        if height != nil {
            coder.encodeInt32(Int32(height!), forKey: "height")
        }
        if action != nil {
            print("\(Int32(action!))")
            coder.encodeInt32(Int32(action!), forKey: "action")
        }
        if label != nil {
            coder.encodeObject(label!, forKey: "label")
        }
        if imageURL != nil {
            coder.encodeObject(imageURL!, forKey: "imageURL")
        }
    }
}

class ControllerData: NSObject {
    var buttons: [ButtonData] = []
    var name: String?
    
    override init() {
        super.init()
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        name = decoder.decodeObjectForKey("name") as? String
        buttons = (decoder.decodeObjectForKey("buttons") as? [ButtonData]) ?? []
    }
    
    func encodeWithCoder(coder: NSCoder) {
        if name != nil {
            coder.encodeObject(name, forKey: "name")
            coder.encodeObject(buttons, forKey: "buttons")
        }
    }
    
    func addButton(button: ButtonData) {
        buttons.append(button)
    }
}
