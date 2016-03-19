//
//  DeviceViewController.swift
//  toe-remote
//


import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController/*, BLEDelegate*/ {
    var ble: BLE?
    var peripheral: CBPeripheral?
    var buttonLayout: ButtonLayout?
    
    init(ble: BLE, peripheral: CBPeripheral, buttonLayout: ButtonLayout?) {
        self.ble = ble
        self.peripheral = peripheral
        self.buttonLayout = buttonLayout
        super.init(nibName: nil, bundle: nil)
        //self.ble!.delegate = self
    }
    
    override func viewDidLoad() {
        buttonLayout?.addToView(self.view)
        
        guard let peripheral = peripheral else { return }
        ble?.connectToPeripheral(peripheral)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    func bleDidScanTimeout() { }
    
    func bleDidUpdateState(state: CBCentralManagerState) {
        if state == .PoweredOn {
        }
    }
    
    func bleDidConnectToPeripheral() {
        print("[DEBUG] Connected to peripheral")
    }
    
    func bleDidDisconenctFromPeripheral() {
        print("[DEBUG] Disconnected from peripheral")
    }
    
    func bleDidReceiveData(data: NSData?) {
        if let d = data {
            NSLog("%@", d)
        }
    }
    */
}