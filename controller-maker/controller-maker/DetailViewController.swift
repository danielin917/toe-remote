//
//  DetailViewController.swift
//  controller-maker
//
//  Created by Nick Terrell on 4/5/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

import Cocoa
import Carbon

protocol ControllerDelegate {
    func didSave()
}

class DetailViewController: NSViewController {
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var buttonsTableView: NSTableView!
    
    @IBOutlet weak var labelField: NSTextField!
    @IBOutlet weak var imageField: NSTextField!
    @IBOutlet weak var xField: NSTextField!
    @IBOutlet weak var yField: NSTextField!
    @IBOutlet weak var widthField: NSTextField!
    @IBOutlet weak var heightField: NSTextField!
    
    @IBOutlet weak var actionLabel: NSTextField!
    
    var capturing: Bool = false
    
    var delegate: ControllerDelegate?
    
    var data: ControllerData? {
        willSet {
            deselectButton()
            print("Saving")
            saveController(self)
            print("Saved")
        }
        didSet {
            nameField.stringValue = data?.name ?? ""
            buttonsTableView.reloadData()
            row = -1
            // The data was updated, so update the view
        }
    }
    var row: Int = -1 {
        willSet {
            saveButton()
        }
        didSet {
            doButtonSelected()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { (aEvent) -> NSEvent? in
            if self.captureKeyDown(aEvent) {
                return nil
            }
            return aEvent
        }
        // Do view setup here.
        
        buttonsTableView.setDataSource(self)
        buttonsTableView.setDelegate(self)
        
        labelField.delegate = self
        imageField.delegate = self
        xField.delegate = self
        yField.delegate = self
        widthField.delegate = self
        heightField.delegate = self
    }
    
    @IBAction func saveController(sender: AnyObject) {
        saveButton()
        data?.name = nilIfEmpty(nameField.stringValue)
        buttonsTableView.reloadData()
        delegate?.didSave()
    }
    
    @IBAction func selectButtonAction(sender: NSButton) {
        guard capturing == false else { return }
        capturing = true
    }
    
    func captureKeyDown(event: NSEvent) -> Bool {
        let keycode = event.keyCode
        if capturing {
            capturing = false
            print("\(translateKeycode(keycode))")
            actionLabel.stringValue = translateKeycode(keycode)
            guard let button = getButton() else { return true }
            button.action = keycode
            return true
        }
        return false
    }
}

// MARK: - TableView DataSource
extension DetailViewController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return data?.buttons.count ?? 0
    }
    
    func selectButtonAtIndex(index: Int) {
        guard let buttons = data?.buttons else { return }
        guard buttons.count > 0 else {
            buttonsTableView.selectRowIndexes(NSIndexSet(), byExtendingSelection: false)
            return
        }
        let indexSet = NSIndexSet(index: min(index, buttons.count - 1))
        buttonsTableView.selectRowIndexes(indexSet, byExtendingSelection: false)
    }
    
    @IBAction func addButton(sender: NSButton) {
        guard data != nil else { return }
        data!.buttons.append(ButtonData())
        buttonsTableView.reloadData()
        selectButtonAtIndex(data!.buttons.count - 1)
    }
    @IBAction func removeButton(sender: NSButton) {
        guard data != nil else { return }
        guard row != -1 else { return }
        let index = row
        deselectButton()
        data!.buttons.removeAtIndex(index)
        buttonsTableView.reloadData()
        // TODO: save state
    }
    
    func getButton() -> ButtonData? {
        guard row != -1 else { return nil }
        guard data != nil else { return nil }
        guard row >= 0 && row < data!.buttons.count else { return nil }
        return data?.buttons[row]
    }
    
    func saveButton() {
        guard let button = getButton() else { return }
        button.label = nilIfEmpty(labelField.stringValue)
        button.imageURL = toURL(imageField.stringValue)
        button.x = toInt(xField.stringValue)
        button.y = toInt(yField.stringValue)
        button.width = toInt(widthField.stringValue)
        button.height = toInt(heightField.stringValue)
    }
    
    func doButtonSelected() {
        let button = row == -1 ? nil : data?.buttons[row]
        
        setStringValue(labelField, value: button?.label)
        setURLValue(imageField, value: button?.imageURL)
        setIntValue(xField, value: button?.x)
        setIntValue(yField, value: button?.y)
        setIntValue(widthField, value: button?.width)
        setIntValue(heightField, value: button?.height)
        setKeycode(actionLabel, value: button?.action)
    }
}

func nilIfEmpty(value: String) -> String? {
    if value.isEmpty {
        return nil
    }
    return value
}

func toInt(value: String) -> UInt8? {
    if value.isEmpty {
        return nil
    }
    return UInt8(value)
}

func toURL(value: String) -> NSURL? {
    if value.isEmpty {
        return nil
    }
    return NSURL(string: value)
}

func setIntValue(field: NSTextField, value: UInt8?) {
    if value == nil {
        field.stringValue = ""
    } else {
        field.stringValue = String(value!)
    }
}

func setStringValue(field: NSTextField, value: String?) {
    if value == nil {
        field.stringValue = ""
    } else {
        field.stringValue = String(value!)
    }
}

func setURLValue(field: NSTextField, value: NSURL?) {
    if value == nil {
        field.stringValue = ""
    } else {
        field.stringValue = String(value!)
    }
}

func setKeycode(field: NSTextField, value: UInt16?) {
    if value == nil {
        field.stringValue = ""
    } else {
        field.stringValue = translateKeycode(value!)
    }
}

// MARK: - TableView Delegate
extension DetailViewController : NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let data = data else { print("nil data"); return nil }
        assert(row < data.buttons.count)
        let button = data.buttons[row]
        
        let cellID = "ButtonCellID"
        
        if let cell = tableView.makeViewWithIdentifier(cellID, owner: nil) as? NSTableCellView {
            if button.label != nil {
                cell.textField?.stringValue = button.label!
            } else {
                cell.textField?.stringValue = "Button"
            }
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard data != nil else { return }
        guard buttonsTableView.numberOfSelectedRows > 0 else { return }
        let index = buttonsTableView.selectedRow
        if index < data?.buttons.count {
            row = index
        } else {
            row = data!.buttons.count - 1
        }
    }
    
    func deselectButton() {
        print("Deselecting controller")
        row = -1
        //detailViewController.data = nil
    }
}

// MARK: - Handle Edits
extension DetailViewController : NSTextFieldDelegate {
    func control(control: NSControl,
                 textShouldEndEditing fieldEditor: NSText) -> Bool {
        control.resignFirstResponder()
        return true;
    }
}


func translateKeycode(keycode: UInt16) -> String {
    switch keycode {
    case UInt16(kVK_LeftArrow):
        return "Left Arrow Key"
    case UInt16(kVK_RightArrow):
        return "Right Arrow Key"
    case UInt16(kVK_UpArrow):
        return "Up Arrow Key"
    case UInt16(kVK_DownArrow):
        return "Down Arrow Key"
    default:
        break
    }
    
    let keyboard = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    let rawLayoutData = TISGetInputSourceProperty(keyboard, kTISPropertyUnicodeKeyLayoutData)
    let layoutData      = unsafeBitCast(rawLayoutData, CFDataRef.self)
    let layout: UnsafePointer<UCKeyboardLayout> =  unsafeBitCast(CFDataGetBytePtr(layoutData), UnsafePointer<UCKeyboardLayout>.self)
    let keyaction           = UInt16(kUCKeyActionDisplay)
    let modifierKeyState    = UInt32(0)
    let keyboardType        = UInt32(LMGetKbdType())
    let keyTranslateOptions = OptionBits(kUCKeyTranslateNoDeadKeysBit)
    var deadKeyState        = UInt32(0)
    let maxStringLength     = 4
    var chars: [UniChar]    = [0,0,0,0]
    var actualStringLength  = 1
    UCKeyTranslate(layout, keycode, keyaction, modifierKeyState, keyboardType, keyTranslateOptions, &deadKeyState, maxStringLength, &actualStringLength, &chars)
    return String(UnicodeScalar(chars[0]))
}
