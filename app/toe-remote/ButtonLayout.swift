//
//  ButtonLayout.swift
//  toe-remote
//


import Foundation
import UIKit

protocol ButtonDelegate {
    func didButtonPress(button: Button)
}

class Button: NSObject {
    var delegate: ButtonDelegate?
    var id: UInt8
    var x: UInt8
    var y: UInt8
    var width: UInt8
    var height: UInt8
    var title: String
    
    var startX: CGFloat?
    var startY: CGFloat?
    var startWidth: CGFloat?
    var startHeight: CGFloat?
    
    var button: UIButton?
    var moveGR: UIPanGestureRecognizer!
    var resizeGR: UIPinchGestureRecognizer!
    
    init(id: UInt8, x: UInt8, y: UInt8, width: UInt8, height: UInt8, title: String) {
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.title = title
        super.init()
        self.moveGR = UIPanGestureRecognizer(target: self, action: Selector("handleMovePan"))
        self.resizeGR = UIPinchGestureRecognizer(target: self, action: Selector("handleResizePinch"))
    }
    
    init(data: NSData, active: Bool) {
        assert(data.length >= 55)
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(data.bytes), count: data.length)
        id = bytes[0]
        x = bytes[1]
        y = bytes[2]
        width = bytes[3]
        height = bytes[4]
        title = String(bytes: bytes.dropFirst(5), encoding: NSUTF8StringEncoding)!
        super.init()
        self.moveGR = UIPanGestureRecognizer(target: self, action: Selector("handleMovePan"))
        self.resizeGR = UIPinchGestureRecognizer(target: self, action: Selector("handleResizePinch"))
    }
    
    func buttonPressed() {
        print("Button pressed: \(id)")
        delegate?.didButtonPress(self)
    }
    
    func normalize(dimension: CGFloat, percent: UInt8) -> CGFloat {
        return CGFloat(percent) * dimension / 100
    }
    
    func denormalize(dimension: CGFloat, position: CGFloat) -> UInt8 {
        return min(100, UInt8(100 * max(0, position) / dimension))
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
            button!.backgroundColor = UIColor.whiteColor()
            button!.setTitle(title, forState: .Normal)
            button!.setTitleColor(UIColor.blueColor(), forState: .Normal)
            button!.addTarget(self, action: Selector("buttonPressed"), forControlEvents: .TouchUpInside)
        }
        print("[DEBUG] Added button with id: \(id) to view")
        view.addSubview(button!)
    }
    
    func moveInView(view: UIView, point: CGPoint) -> CGPoint {
        var result = point
        if point.x < 0 {
            result.x = 0
        }
        if point.y < 0 {
            result.y = 0
        }
        if point.x + startWidth! > view.bounds.width {
            result.x = view.bounds.width - startWidth!
        }
        if point.y + startHeight! > view.bounds.height {
            result.y = view.bounds.height - startHeight!
        }
        return result
    }
    
    func handleMovePan() {
        guard let button = button else { return }
        guard let superview = button.superview else { return }
        switch moveGR.state {
        case .Began:
            startX = normalize(superview.bounds.width, percent: x)
            startY = normalize(superview.bounds.height, percent: y)
            startWidth = normalize(superview.bounds.width, percent: width)
            startHeight = normalize(superview.bounds.height, percent: height)
            superview.bringSubviewToFront(button)
            break
        case .Changed:
            var point = moveGR.translationInView(superview)
            point.x += startX!
            point.y += startY!
            let newPoint = moveInView(superview, point: point)
            button.frame = CGRectMake(newPoint.x, newPoint.y, startWidth!, startHeight!)
            break
        case .Ended:
            var point = moveGR.translationInView(superview)
            point.x += startX!
            point.y += startY!
            let newPoint = moveInView(superview, point: point)
            x = denormalize(superview.bounds.width, position: newPoint.x)
            y = denormalize(superview.bounds.height, position: newPoint.y)
            let newX = normalize(superview.bounds.width, percent: x)
            let newY = normalize(superview.bounds.height, percent: y)
            button.frame = CGRectMake(newX, newY, startWidth!, startHeight!)
            break
        default:
            break
        }
    }
    
    func boundScale(scale: CGFloat) -> CGFloat {
        assert(scale > 0)
        let superview = button!.superview!
        var dx = (button!.frame.width - scale*button!.frame.width) / 2
        var dy = (button!.frame.height - scale*button!.frame.height) / 2
        
        if startX! + dx < 0 {
            dx = -startX!
        }
        if startY! + dy < 0 {
            dy = -startY!
        }
        if startX! + button!.bounds.width - dx > superview.bounds.width {
            dx = (startX! + button!.bounds.width) - superview.bounds.width
        }
        if startY! + button!.bounds.height - dy > superview.bounds.height {
            dy = (startY! + button!.bounds.height) - superview.bounds.height
        }
        let scaleX = 1 - 2*dx/button!.frame.width
        let scaleY = 1 - 2*dy/button!.frame.height
        return min(scaleX, scaleY)
    }
    
    func handleResizePinch() {
        guard let button = button else { return }
        guard let superview = button.superview else { return }
        switch resizeGR.state {
        case .Began:
            print("resize began")
            startX = normalize(superview.bounds.width, percent: x)
            startY = normalize(superview.bounds.height, percent: y)
            startWidth = normalize(superview.bounds.width, percent: width)
            startHeight = normalize(superview.bounds.height, percent: height)
            superview.bringSubviewToFront(button)
            break
        case .Changed:
            print("resize changed")
            let scale = boundScale(resizeGR.scale)
            resizeGR.scale = scale
            let dx = (button.frame.width - scale*button.frame.width) / 2
            let dy = (button.frame.height - scale*button.frame.height) / 2
            button.frame = CGRectMake(startX! + dx, startY! + dy, startWidth! - 2*dx, startHeight! - 2*dy)
            break
        case .Ended:
            print("resize ended")
            let scale = boundScale(resizeGR.scale)
            resizeGR.scale = scale
            let dx = (button.frame.width - scale*button.frame.width) / 2
            let dy = (button.frame.height - scale*button.frame.height) / 2
            x = denormalize(superview.bounds.width, position: startX! + dx)
            y = denormalize(superview.bounds.height, position: startY! + dy)
            width = denormalize(superview.bounds.width, position: startWidth! - 2*dx)
            height = denormalize(superview.bounds.height, position: startHeight! - 2*dy)
            
            let newX = normalize(superview.bounds.width, percent: x)
            let newY = normalize(superview.bounds.height, percent: y)
            let newWidth = normalize(superview.bounds.width, percent: width)
            let newHeight = normalize(superview.bounds.height, percent: height)
            button.frame = CGRectMake(newX, newY, newWidth, newHeight)
            break
        default:
            break
        }
    }
    
    func edit(isEditing: Bool) {
        if isEditing {
            button?.addGestureRecognizer(moveGR)
            button?.addGestureRecognizer(resizeGR)
        } else {
            button?.removeGestureRecognizer(moveGR)
            button?.removeGestureRecognizer(resizeGR)
        }
    }
}

class ButtonLayout: NSObject {
    var buttons: Array<Button>
    var thumbnail: UIImage?
    
    override init() {
        self.buttons = Array<Button>()
        super.init()
    }
    
    func addButton(delegate: ButtonDelegate, data: NSData, active: Bool) {
        print("[DEBUG] Adding a button to the layout")
        let button = Button(data: data, active: active)
        button.delegate = delegate
        buttons.append(button)
        
    }
    
    func setDelegate(delegate: ButtonDelegate) {
        for button in buttons {
            button.delegate = delegate
        }
    }
    
    func removeFromView() {
        for button in buttons {
            button.button?.removeFromSuperview()
        }
    }
    
    func makeThumbnail(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func addToView(view: UIView) {
        print("[DEBUG] Adding buttons to view")
        for button in buttons {
            button.addToView(view)
        }
        if thumbnail == nil {
            makeThumbnail(view)
        }
    }
    
    func edit(isEditing: Bool) {
        for button in buttons {
            button.edit(isEditing)
        }
    }
}