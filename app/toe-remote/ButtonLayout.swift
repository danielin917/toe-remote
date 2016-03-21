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
    
    var button: UIButton?
    
    init(ble: BLE, id: UInt8, x: UInt8, y: UInt8, width: UInt8, height: UInt8, title: String) {
        self.ble = ble
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.title = title
        super.init()
    }
    
    init(ble: BLE, data: NSData) {
        self.ble = ble
        assert(data.length >= 55)
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(data.bytes), count: data.length)
        id = bytes[0]
        x = bytes[1]
        y = bytes[2]
        width = bytes[3]
        height = bytes[4]
        title = String(bytes: bytes.dropFirst(5), encoding: NSUTF8StringEncoding)!
        super.init()
    }
    
    func sendButtonPress() {
        let bytes: [UInt8] = [0x01, id]
        ble.write(data: NSData(bytes: bytes, length: 2))
    }
    
    func normalize(dimension: CGFloat, percent: UInt8) -> CGFloat {
        return CGFloat(percent) * dimension / 100
    }
    
    func addToView(view: UIView) -> UIView {
        guard button == nil else { return button! }
        
        // Scale to view bounds
        let viewHeight = view.bounds.height
        let viewWidth = view.bounds.width
        let rX = normalize(viewWidth, percent: x)
        let rY = normalize(viewHeight, percent: y)
        let rWidth = normalize(viewWidth, percent: width)
        let rHeight = normalize(viewHeight, percent: height)
        
        button = UIButton(frame: CGRectMake(rX, rY, rWidth, rHeight))
        button!.setTitle(title, forState: .Normal)
        
        button?.addTarget(self, action: Selector("sendButtonPress"), forControlEvents: .TouchUpInside)
        
        return button!
    }
}

class ButtonLayout: NSObject {
    var buttons: Array<Button>
    
    override init() {
        self.buttons = Array<Button>()
        super.init()
    }
    
    func addButton(ble: BLE, data: NSData) {
        buttons.append(Button(ble: ble, data: data))
    }
    
    func addToView(view: UIView) {
        for button in buttons {
            button.addToView(view)
        }
    }
}