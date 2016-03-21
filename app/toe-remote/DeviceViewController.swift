//
//  DeviceViewController.swift
//  toe-remote
//


import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController, BLEDelegate {
    var ble: BLE?
    var peripheral: CBPeripheral
    var buttonLayout: ButtonLayout?
    var readBuffer: NSMutableData
    var index: Int
    var numButtons: UInt8?
    var buttonView: UIView!
    var selectionViewController: SelectionViewController?
    var viewLoaded: Bool
    
    init(selectionViewController: SelectionViewController?, ble: BLE?, peripheral: CBPeripheral) {
        self.selectionViewController = selectionViewController
        self.ble = ble
        self.peripheral = peripheral
        self.buttonLayout = selectionViewController?.cachedLayouts[peripheral.identifier.UUIDString]
        self.readBuffer = NSMutableData()
        self.index = 0
        self.viewLoaded = false
        super.init(nibName: nil, bundle: nil)
        
        let titleHeight = self.view.bounds.height / 10.0
        self.buttonView = UIView(frame: CGRectMake(0, titleHeight, self.view.bounds.width, titleHeight * 9.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Method not implemented")
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.whiteColor()
        addTitleView(self.view)
        if buttonLayout != nil {
            buttonLayout!.addToView(buttonView)
        }
        viewLoaded = true
    }
    
    func saveLayout() {
        guard let buttonLayout = buttonLayout else { return }
        let key = peripheral.identifier.UUIDString
        selectionViewController?.cachedLayouts.updateValue(buttonLayout, forKey: key)
    }
    
    func popView() {
        ble?.disconnectFromPeripheral(peripheral)
        self.dismissViewControllerAnimated(true, completion: {();
            guard let selectionViewController = self.selectionViewController else { return }
            self.ble?.delegate = selectionViewController
            selectionViewController.retrieveNearbyDevices()
        })
    }
    
    func addTitleView(view: UIView) {
        let titleBar = UIView(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height / 10))
        let backButtonWidth: CGFloat = 100.0
        
        let title = UILabel(frame: CGRectMake(backButtonWidth, 0, titleBar.bounds.width - 2*backButtonWidth, titleBar.bounds.size.height))
        title.text = self.peripheral.name
        title.textAlignment = .Center
        titleBar.addSubview(title)
        
        let backButton = UIButton(frame: CGRectMake(0, 0, backButtonWidth, titleBar.bounds.size.height))
        backButton.setTitle("Back", forState: .Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        if selectionViewController != nil {
            backButton.addTarget(self, action: Selector("popView"), forControlEvents: .TouchUpInside)
        }
        titleBar.addSubview(backButton)
        
        view.addSubview(titleBar)
    }
    
    func bleDidScanTimeout() { }
    
    func bleDidUpdateState(state: CBCentralManagerState) {
        if state == .PoweredOn {
        }
    }
    
    func bleDidConnectToPeripheral() {
        print("[DEBUG] Connected to peripheral")
        if buttonLayout == nil {
            buttonLayout = ButtonLayout()
            let bytes: [UInt8] = [0x00, 0x00]
            ble?.write(data: NSData(bytes: bytes, length: 2))
        }
    }
    
    func bleDidDisconenctFromPeripheral() {
        print("[DEBUG] Disconnected from peripheral")
        popView()
    }
    
    func bleDidReceiveData(data: NSData?) {
        guard let buttonLayout = buttonLayout else { return }
        guard let data = data else { return }
        readBuffer.appendData(data)
        guard readBuffer.length - index > 0 else { return }
        if numButtons == nil {
            numButtons = UnsafePointer<UInt8>(readBuffer.bytes).memory
            ++index
        }
        guard let ble = ble else { return }
        while numButtons > 0 && readBuffer.length - index >= 55 {
            let range = NSRange(location: index, length: 55)
            let active = selectionViewController != nil
            buttonLayout.addButton(ble, data: readBuffer.subdataWithRange(range), active: active)
            index += 55
            --numButtons!
        }
        if numButtons == 0 {
            print("[DEBUG] Recieved the layout")
            saveLayout()
            if self.viewLoaded {
                buttonLayout.addToView(buttonView)
            }
        }
    }
    
}