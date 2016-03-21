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
    
    var target: AnyObject!
    var action: Selector!
    
    init(ble: BLE, id: UInt8, x: UInt8, y: UInt8, width: UInt8, height: UInt8, title: String) {
        self.ble = ble
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.title = title
        super.init()
        setTargetAction(nil, action: nil)
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
        super.init()
        setTargetAction(nil, action: nil)
    }
    
    func setTargetAction(target: AnyObject?, action: Selector?) {
        var realTarget: AnyObject
        if target == nil {
            realTarget = self
        } else {
            realTarget = target!
        }
        var realAction: Selector
        if action == nil {
            realAction = Selector("sendButtonPress")
        } else {
            realAction = action!
        }
        if button != nil {
            button!.removeTarget(self.target, action: self.action, forControlEvents: .TouchUpInside)
            button!.addTarget(realTarget, action: realAction, forControlEvents: .TouchUpInside)
        }
        self.target = realTarget
        self.action = realAction
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
        if button == nil {
            // Scale to view bounds
            let viewHeight = view.bounds.height
            let viewWidth = view.bounds.width
            let rX = normalize(viewWidth, percent: x)
            let rY = normalize(viewHeight, percent: y)
            let rWidth = normalize(viewWidth, percent: width)
            let rHeight = normalize(viewHeight, percent: height)
            
            button = UIButton(frame: CGRectMake(rX, rY, rWidth, rHeight))
            button!.layer.cornerRadius = 10
            button!.layer.borderColor = UIColor.blackColor().CGColor
            button!.layer.borderWidth = 1
            button!.setTitle(title, forState: .Normal)
            button!.setTitleColor(UIColor.blueColor(), forState: .Normal)
            button!.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        }
        print("[DEBUG] Added button with id: \(id) to view")
        view.addSubview(button!)
    }
}

class ButtonLayout: NSObject {
    var buttons: Array<Button>
    var thumbnail: UIImage?
    
    override init() {
        self.buttons = Array<Button>()
        super.init()
    }
    
    func addButton(ble: BLE, data: NSData, active: Bool) {
        print("[DEBUG] Adding a button to the layout")
        buttons.append(Button(ble: ble, data: data, active: active))
    }
    
    func setTargetAction(target: AnyObject?, action: Selector) {
        for button in buttons {
            button.setTargetAction(target, action: action)
        }
    }
    
    func addToView(view: UIView) {
        print("[DEBUG] Adding buttons to view")
        for button in buttons {
            button.addToView(view)
        }
        if thumbnail == nil {
            UIGraphicsBeginImageContext(view.frame.size)
            view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            thumbnail = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
}