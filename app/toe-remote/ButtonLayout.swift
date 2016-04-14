//
//  ButtonLayout.swiftr
//  toe-remote
//


import Foundation
import UIKit

protocol ButtonDelegate {
    func didButtonPress(button: Button)
    func buttonUpdated(button: Button)
}

class Button: NSObject {
    static let length = 313
    
    var delegate: ButtonDelegate?
    var id: UInt8
    var x: UInt8
    var y: UInt8
    var width: UInt8
    var height: UInt8
    var title: String
    var border: Bool
    var imageURL: NSURL?
    
    var image: UIImage? {
        didSet {
            print("We found the image, adding now!")
            addImage()
        }
    }
    
    var startX: CGFloat?
    var startY: CGFloat?
    var startWidth: CGFloat?
    var startHeight: CGFloat?
    
    var frame: CGRect?
    
    var button: UIButton?
    var moveGR: UIPanGestureRecognizer!
    var resizeGR: UIPinchGestureRecognizer!
    var editing: Bool = false
    
    /*init(id: UInt8, x: UInt8, y: UInt8, width: UInt8, height: UInt8, title: String, border: Bool) {
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.title = title
        self.border = border
        super.init()
        self.moveGR = UIPanGestureRecognizer(target: self, action: #selector(handleMovePan))
        self.resizeGR = UIPinchGestureRecognizer(target: self, action: #selector(handleResizePinch))
    }*/
    
    init(data: NSData, active: Bool) {
        assert(data.length >= Button.length)
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(data.bytes), count: data.length)
        id = bytes[0]
        x = bytes[1]
        y = bytes[2]
        width = bytes[3]
        height = bytes[4]
        border = (bytes[5] == UInt8(1))
        let imageLength: UInt8 = bytes[6]
        // 50 bytes
        let t = String(bytes: dropNull(bytes.dropFirst(7).dropLast(256)), encoding: NSUTF8StringEncoding)
        assert(t != nil)
        title = t!
        super.init()
        if (imageLength > 0) {
            let urlStr = String(bytes: dropNull(bytes.dropFirst(57)), encoding: NSUTF8StringEncoding)
            assert(urlStr != nil)
            print("Image is: \(urlStr)")
            imageURL = NSURL(string: urlStr!)
            if imageURL != nil {
                print("Setting up image to load")
                self.loadImageFromURL(imageURL!)
            }
        }
        self.moveGR = UIPanGestureRecognizer(target: self, action: #selector(handleMovePan))
        self.resizeGR = UIPinchGestureRecognizer(target: self, action: #selector(handleResizePinch))
    }
    
    func loadImageFromURL(imageURL: NSURL) {
        let request = NSURLRequest(URL: imageURL)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request,  completionHandler: { (data, response, error) -> Void in
            print("Got response")
            var image: UIImage? = nil
            if error == nil && data != nil {
                image = UIImage(data: data!)
                print("No errors")
            } else {
                print(error)
            }
            dispatch_async(dispatch_get_main_queue(), {
                print("Set the image: \(image == nil)")
                self.image = image
            })
        })
        task.resume();
    }
    
    func addImage() {
        guard let image = image else { return }
        guard let button = button else { return }
        print("Added")
        button.removeTarget(self, action: #selector(Button.buttonPressed), forControlEvents: .TouchUpInside)
        button.setTitle("", forState: .Normal)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(Button.buttonPressed), forControlEvents: .TouchUpInside)
        delegate?.buttonUpdated(self)
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
        if imageURL != nil && image == nil {
            loadImageFromURL(imageURL!)
        }
        if button == nil {
            // Scale to view bounds
            let viewHeight = view.bounds.height
            let viewWidth = view.bounds.width
            let rX = normalize(viewWidth, percent: x)
            let rY = normalize(viewHeight, percent: y)
            let rWidth = normalize(viewWidth, percent: width)
            let rHeight = normalize(viewHeight, percent: height)
            
            button = UIButton(type: .System)
            button!.frame = CGRectMake(rX, rY, rWidth, rHeight)
            if border {
                button!.layer.cornerRadius = 10
                button!.layer.borderColor = UIColor.blackColor().CGColor
                button!.layer.borderWidth = 1
            }
            if image == nil {
                button!.backgroundColor = UIColor.whiteColor()
                button!.setTitle(title, forState: .Normal)
                button!.setTitleColor(UIColor.blueColor(), forState: .Normal)
                makeAccessible(button?.titleLabel)
                button!.addTarget(self, action: #selector(Button.buttonPressed), forControlEvents: .TouchUpInside)
            } else {
                addImage()
            }
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
        assert(editing)
        guard let button = button else { return }
        guard let superview = button.superview else { return }
        switch moveGR.state {
        case .Began:
            moveGR.cancelsTouchesInView = true
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
            x = denormalize(superview.bounds.width, position: newPoint.x)
            y = denormalize(superview.bounds.height, position: newPoint.y)
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
        
        if (button!.bounds.width - 2*dx) / superview.bounds.width < 0.2 {
            dx = (button!.bounds.width - 0.2 * superview.bounds.width) / 2
        }
        if (button!.bounds.height - 2*dy) / superview.bounds.height < 0.2 {
            dy = (button!.bounds.height - 0.2 * superview.bounds.height) / 2
        }
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
        assert(editing)
        guard let button = button else { return }
        guard let superview = button.superview else { return }
        switch resizeGR.state {
        case .Began:
            resizeGR.cancelsTouchesInView = true
            startX = normalize(superview.bounds.width, percent: x)
            startY = normalize(superview.bounds.height, percent: y)
            startWidth = normalize(superview.bounds.width, percent: width)
            startHeight = normalize(superview.bounds.height, percent: height)
            superview.bringSubviewToFront(button)
            break
        case .Changed:
            let scale = boundScale(resizeGR.scale)
            resizeGR.scale = scale
            let dx = (button.frame.width - scale*button.frame.width) / 2
            let dy = (button.frame.height - scale*button.frame.height) / 2
            x = denormalize(superview.bounds.width, position: startX! + dx)
            y = denormalize(superview.bounds.height, position: startY! + dy)
            width = denormalize(superview.bounds.width, position: startWidth! - 2*dx)
            height = denormalize(superview.bounds.height, position: startHeight! - 2*dy)
            button.frame = CGRectMake(startX! + dx, startY! + dy, startWidth! - 2*dx, startHeight! - 2*dy)
            break
        case .Ended:
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
    
    func cancel() {
        guard editing else { return }
        guard let superview = button?.superview else { return }
        guard let frame = frame else { return }
        x = denormalize(superview.bounds.width, position: frame.minX)
        y = denormalize(superview.bounds.height, position: frame.minY)
        width = denormalize(superview.bounds.width, position: frame.width)
        height = denormalize(superview.bounds.height, position: frame.height)
        button?.frame = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        edit(false)
    }
    
    func save() {
        guard editing else { return }
        frame = button?.frame
        edit(false)
    }
    
    func edit(isEditing: Bool) {
        editing = isEditing
        if isEditing {
            frame = button?.frame
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
    
    func setDelegate(delegate: ButtonDelegate?) {
        for button in buttons {
            button.delegate = delegate
        }
    }
    
    func removeFromView() {
        for button in buttons {
            button.button?.removeFromSuperview()
        }
    }
    
    func clear() {
        thumbnail = nil
        buttons.removeAll()
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
    
    func edit() {
        for button in buttons {
            button.edit(true)
        }
    }
    
    func cancel() {
        for button in buttons {
            button.cancel()
        }
    }
    
    func save() {
        for button in buttons {
            button.save()
        }
    }
}