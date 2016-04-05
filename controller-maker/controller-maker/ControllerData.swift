//
//  ControllerData.swift
//  controller-maker
//
//  Created by Nick Terrell on 4/3/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

import Cocoa


class ButtonData: NSObject {
    var x: UInt8 = 40
    var y: UInt8 = 40
    var width: UInt8 = 20
    var height: UInt8 = 20
    
    var label: String = String()
    var image: NSImage?
    
    var actions: [Action] = []
}

class ControllerData: NSObject {
    var buttons: [ButtonData] = []
    var name: String
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    func addButton(button: ButtonData) {
        buttons.append(button)
    }
}
