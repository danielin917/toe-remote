//
//  ViewController.swift
//  toe-remote
//


import UIKit
import CoreBluetooth

class SelectionViewCell: UICollectionViewCell {
    var textLabel: UILabel!
    var buttonView: UIView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/3))
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
        
        buttonView = UIView(frame: CGRect(x: 0, y: textLabel.frame.size.height, width: frame.size.width, height: frame.size.height*2/3))
        contentView.addSubview(buttonView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class SelectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, BLEDelegate {

    var collectionView: UICollectionView!
    var ble: BLE!
    var cachedLayouts: Dictionary<String, ButtonLayout>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        cachedLayouts = Dictionary()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        let width = view.bounds.width / 3
        let height = view.bounds.height / 2
        layout.itemSize = CGSize(width: width, height: height)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(SelectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
        
        ble = BLE()
        ble.delegate = self
        retrieveNearbyDevices()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ble.peripherals.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SelectionViewCell
        assert(ble.peripherals.count > indexPath.item)
        let peripheral = ble.peripherals[indexPath.item]
        cell.textLabel.text = peripheral.name
        if let layout = cachedLayouts[peripheral.identifier.UUIDString] {
            layout.addToView(cell.buttonView)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("[DEBUG] Selected item: ", indexPath.item)
        assert(ble.peripherals.count > indexPath.item)
        
        let peripheral = ble.peripherals[indexPath.item]
        let deviceViewController = DeviceViewController(selectionViewController: self, ble: ble, peripheral: peripheral)
        self.presentViewController(deviceViewController, animated: true, completion: {();
            self.ble.delegate = deviceViewController
            self.ble.connectToPeripheral(peripheral)
        })
    }
    
    func bleDidScanTimeout() {
        print("[DEBUG] Scan Timeout")
        self.collectionView.reloadData()
    }
    
    func bleDidUpdateState(state: CBCentralManagerState) {
        if state == .PoweredOn {
            retrieveNearbyDevices()
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
    
    func retrieveNearbyDevices() {
        ble.startScanning(1)
    }

    func cleanup() {
        ble.cleanup()
    }

}

