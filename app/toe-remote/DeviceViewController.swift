//
//  DeviceViewController.swift
//  toe-remote
//


import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController, BLEDelegate {
    var ble: BLE?
    var peripheral: CBPeripheral?
    var buttonLayout: ButtonLayout?
    var readBuffer: NSMutableData
    var index: Int
    var numButtons: UInt8?
    var buttonView: UIView!
    var selectionViewController: SelectionViewController
    
    init(selectionViewController: SelectionViewController, ble: BLE, peripheral: CBPeripheral, buttonLayout: ButtonLayout?) {
        self.selectionViewController = selectionViewController
        self.ble = ble
        self.peripheral = peripheral
        self.buttonLayout = buttonLayout
        self.readBuffer = NSMutableData()
        self.index = 0
        super.init(nibName: nil, bundle: nil)
        
        let titleHeight = self.view.bounds.height / 10.0
        self.buttonView = UIView(frame: CGRectMake(0, titleHeight, self.view.bounds.width, titleHeight * 9.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.selectionViewController = SelectionViewController()
        self.readBuffer = NSMutableData()
        self.index = 0
        super.init(coder: aDecoder)
        let titleHeight = self.view.bounds.height / 10.0
        self.buttonView = UIView(frame: CGRectMake(0, titleHeight, self.view.bounds.width, titleHeight * 9.0))
    }
    
    override func viewDidLoad() {
        addTitleView(self.view)
        buttonLayout?.addToView(buttonView)
    }
    
    func popView() {
        if let peripheral = peripheral {
            ble?.disconnectFromPeripheral(peripheral)
        }
        self.dismissViewControllerAnimated(true, completion: {();
            self.ble?.delegate = self.selectionViewController
            self.selectionViewController.retrieveNearbyDevices()
        })
    }
    
    func addTitleView(view: UIView) {
        let titleBar = UIView(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height / 10))
        let backButtonWidth: CGFloat = 100.0
        
        let title = UILabel(frame: CGRectMake(backButtonWidth, 0, titleBar.bounds.width - 2*backButtonWidth, titleBar.bounds.size.height))
        title.text = self.peripheral!.name
        title.textAlignment = .Center
        titleBar.addSubview(title)
        
        let backButton = UIButton(frame: CGRectMake(0, 0, backButtonWidth, titleBar.bounds.size.height))
        backButton.setTitle("Back", forState: .Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        backButton.addTarget(self, action: Selector("popView"), forControlEvents: .TouchUpInside)
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
            buttonLayout.addButton(ble, data: readBuffer.subdataWithRange(range))
            index += 55
            --numButtons!
        }
        if numButtons == 0 {
            print("[DEBUG] Recieved the layout")
            buttonLayout.addToView(buttonView)
        }
    }
    
}