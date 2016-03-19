//
//  ButtonLayout.swift
//  toe-remote
//


import Foundation
import UIKit

class Button: NSObject {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var title: String
    
    var _view: UIButton?
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, title: String) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.title = title
        super.init()
    }
    
    init(data: NSData) {
        assert(data.length >= 55)
        x = 0
        y = 0
        width = 0
        height = 0
        title = ""
        
        super.init()
    }
    
    func view() -> UIView {
        guard _view == nil else { return _view! }
        
        _view = UIButton.init(frame: CGRectMake(x, y, width, height))
        _view!.setTitle(title, forState: .Normal)
        return _view!
    }
}

class ButtonLayout: NSObject {
    var buttons: Array<Button>
    
    override init() {
        self.buttons = Array<Button>()
        super.init()
    }
    
    func addToView(view: UIView) {
        for button in buttons {
            view.addSubview(button.view())
        }
    }
}