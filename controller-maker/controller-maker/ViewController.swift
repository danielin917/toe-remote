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
    var detailViewController: DetailViewController!
    var server: ServerInterfaceObjC?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controllersTableView.setDelegate(self)
        controllersTableView.setDataSource(self)
        
        loadControllers()
        // Do any additional setup after loading the view.
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationController as? DetailViewController
            where segue.identifier == "EmbedDetailSegue" else { return }
        detailViewController = vc
        detailViewController.delegate = self
    }
    
    func selectControllerAtIndex(index: Int) {
        guard controllers.count > 0 else {
            controllersTableView.selectRowIndexes(NSIndexSet(), byExtendingSelection: false)
            return
        }
        let indexSet = NSIndexSet(index: min(index, controllers.count - 1))
        controllersTableView.selectRowIndexes(indexSet, byExtendingSelection: false)
    }
    
    // MARK: - IBActions
    @IBAction func addController(sender: AnyObject) {
        controllers.append(ControllerData())
        controllersTableView.reloadData()
        selectControllerAtIndex(controllers.count - 1)
    }
    
    @IBAction func removeController(sender: AnyObject) {
        guard let selectedController = detailViewController.data else { return }
        guard let index = controllers.indexOf(selectedController) else { return }
        controllers.removeAtIndex(index)
        controllersTableView.reloadData()
        // TODO: save state
        deselectController()
    }
}


// MARK: - TableView DataSource
extension ViewController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return controllers.count
    }
}

// MARK: - TableView Delegate
extension ViewController : NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellID = "ControllerCellID"
        if let cell = tableView.makeViewWithIdentifier(cellID, owner: nil) as? NSTableCellView {
            let controller = controllers[row]
            if controller.name != nil {
                cell.textField?.stringValue = controllers[row].name!
            } else {
                cell.textField?.stringValue = "Controller"
            }
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard controllersTableView.numberOfSelectedRows > 0 else {
            return
        }
        let index = controllersTableView.selectedRow
        if index < controllers.count {
            detailViewController.data = controllers[index]
        } else {
             detailViewController.data = controllers.last
        }
    }
    
    func deselectController() {
        print("Deselecting controller")
        detailViewController.data = nil
    }
}

// Mark: - Controller Delegate
extension ViewController : ControllerDelegate {
    func didSave() {
        guard let selectedController = detailViewController.data else { return }
        guard let index = controllers.indexOf(selectedController) else { return }
        controllersTableView.reloadDataForRowIndexes(NSIndexSet(index: index), columnIndexes: NSIndexSet(index: 0))
        saveControllers()
    }
    
    func saveControllers() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.controllers)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "controllers")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func loadControllers() {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("controllers") as? NSData {
            self.controllers = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [ControllerData]
        } else {
            self.controllers = []
        }
        controllersTableView.reloadData()
    }
}

extension ViewController {
    @IBAction func stopButtonPressed(sender: AnyObject) {
        print("STOP in the name of love")
        server = nil
    }
    
    @IBAction func runButtonPressed(sender: AnyObject) {
        print("Running awawy")
        guard let data = self.detailViewController.data else { return }
        guard let name = data.name else { return }
        self.server = ServerInterfaceObjC(name)
        for button in data.buttons {
            print("\(button.imageURL == nil)")
            guard let label = button.label else { continue }
            guard let x = button.x else { continue }
            guard let y = button.y else { continue }
            guard let width = button.width else { continue }
            guard let height = button.height else { continue }
            guard let action = button.action else { continue }
            self.server?.addButton(label, imageURL: button.imageURL, x: x, y: y, width: width, height: height, action: action)
        }
        self.server?.start();
    }
}