//
//  ButtonLayout.swift
//  toe-remote
//


import Foundation
import UIKit

class Button: NSObject {
    var ble: BLE
    var id: UInt8
    var x: UInt8
    var y: UInt8
    var width: UInt8
    var height: UInt8
    var title: String
    
    var active: Bool
    
    init(ble: BLE, id: UInt8, x: UInt8, y: UInt8, width: UInt8, height: UInt8, title: String, active: Bool) {
        self.ble = ble
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.title = title
        self.active = active
        super.init()
    }
    
    init(ble: BLE, data: NSData, active: Bool) {
        self.ble = ble
        assert(data.length >= 55)
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(data.bytes), count: data.length)
        id = bytes[0]
        x = bytes[1]
        y = bytes[2]
        width = bytes[3]
        height = bytes[4]
        title = String(bytes: bytes.dropFirst(5), encoding: NSUTF8StringEncoding)!
        self.active = active
        super.init()
    }
    
    func sendButtonPress() {
        print("Sending button press: \(id)")
        let bytes: [UInt8] = [0x01, id]
        ble.write(data: NSData(bytes: bytes, length: 2))
    }
    
    func normalize(dimension: CGFloat, percent: UInt8) -> CGFloat {
        return CGFloat(percent) * dimension / 100
    }
    
    func addToView(view: UIView) {
        // Scale to view bounds
        let viewHeight = view.bounds.height
        let viewWidth = view.bounds.width
        let rX = normalize(viewWidth, percent: x)
        let rY = normalize(viewHeight, percent: y)
        let rWidth = normalize(viewWidth, percent: width)
        let rHeight = normalize(viewHeight, percent: height)
        
        let button = UIButton(frame: CGRectMake(rX, rY, rWidth, rHeight))
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        if active {
            button.addTarget(self, action: Selector("sendButtonPress"), forControlEvents: .TouchUpInside)
        }
        print("[DEBUG] Added button with id: \(id) to view")
        view.addSubview(button)
    }
}

class ButtonLayout: NSObject {
    var buttons: Array<Button>
    
    override init() {
        self.buttons = Array<Button>()
        super.init()
    }
    
    func addButton(ble: BLE, data: NSData, active: Bool) {
        print("[DEBUG] Adding a button to the layout")
        buttons.append(Button(ble: ble, data: data, active: active))
    }
    
    func addToView(view: UIView) {
        print("[DEBUG] Adding buttons to view")
        for button in buttons {
            button.addToView(view)
        }
    }
}