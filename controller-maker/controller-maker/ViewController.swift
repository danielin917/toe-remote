//
//  ViewController.swift
//  controller-maker
//
//  Created by Nick Terrell on 3/31/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var controllersTableView: NSTableView!
    
    var controllers: [ControllerData] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        controllersTableView.setDelegate(self)
        controllersTableView.setDataSource(self)
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
            guard let controller = representedObject as? ControllerData else { return }
            print(controller.name)
        }
    }
}

extension ViewController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return controllers.count
    }
}

extension ViewController : NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        
    }
}