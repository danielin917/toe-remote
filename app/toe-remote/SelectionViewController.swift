//
//  ViewController.swift
//  toe-remote
//


import UIKit
import CoreBluetooth

class SelectionViewCell: UICollectionViewCell {
    var textLabel: UILabel!
    var buttonView: UIImageView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 1
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/3))
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
        
        buttonView = UIImageView(frame: CGRect(x: 0, y: textLabel.frame.size.height, width: frame.size.width, height: frame.size.height*2/3))
        buttonView.contentMode = UIViewContentMode.ScaleAspectFit
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
    var deviceViewController: DeviceViewController?
    
    var peripherals: [CBPeripheral] = []
    var progress: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        cachedLayouts = Dictionary()
        
        addTitleView(self.view)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        let width = view.bounds.width / 3 - 20
        let height = view.bounds.height / 2
        layout.itemSize = CGSize(width: width, height: height)
        
        collectionView = UICollectionView(frame: CGRectMake(0, view.bounds.height/10, view.bounds.width, view.bounds.height*9/10), collectionViewLayout: layout)
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
    
    func refresh() {
        retrieveNearbyDevices()
    }
    
    func addTitleView(view: UIView) {
        let titleBar = UIView(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height / 10))
        let backButtonWidth: CGFloat = 100.0
        
        let title = UILabel(frame: CGRectMake(backButtonWidth, 0, titleBar.bounds.width - 2*backButtonWidth, titleBar.bounds.size.height))
        title.text = "Toe Remote"
        title.textAlignment = .Center
        titleBar.addSubview(title)
        
        let refreshButton = UIButton(frame: CGRectMake(titleBar.bounds.width - backButtonWidth, 0, backButtonWidth, titleBar.bounds.size.height))
        refreshButton.setTitle("Refresh", forState: .Normal)
        refreshButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        refreshButton.addTarget(self, action: #selector(refresh), forControlEvents: .TouchUpInside)
        titleBar.addSubview(refreshButton)
        
        view.addSubview(titleBar)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SelectionViewCell
        assert(peripherals.count > indexPath.item)
        let peripheral = peripherals[indexPath.item]
        cell.textLabel.text = ble.getName(peripheral)
        cell.buttonView.image = cachedLayouts[peripheral.identifier.UUIDString]?.thumbnail
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("[DEBUG] Selected item: ", indexPath.item)
        assert(peripherals.count > indexPath.item)
        
        let peripheral = peripherals[indexPath.item]
        if deviceViewController?.peripheral != peripheral {
            deviceViewController = DeviceViewController(selectionViewController: self, ble: ble, peripheral: peripheral)
        }
        self.presentViewController(deviceViewController!, animated: true, completion: {();
            self.ble.delegate = self.deviceViewController!
            self.ble.connectToPeripheral(peripheral)
        })
    }
    
    func bleDidScanTimeout() {
        print("[DEBUG] Scan Timeout")
        progress!.stopAnimating()
        peripherals = ble.peripherals
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
        print("[DEBUG] Retrieving Nearby Devices")
        if progress == nil {
            progress = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            let width: CGFloat = 100
            progress!.frame = CGRectMake((self.view.bounds.width - width)/2, (self.view.bounds.height - width)/2, width, width)
            self.view.addSubview(progress!)
        }
        progress!.startAnimating()
        ble.startScanning(1)
    }
    
    func resume() {
        print("Resuming")
        if deviceViewController != nil {
            deviceViewController!.resume()
        } else {
            retrieveNearbyDevices()
        }
    }

    func pause() {
        print("Pausing")
        if deviceViewController != nil {
            deviceViewController?.pause()
        }
        ble.cleanup()
        self.collectionView.reloadData()
    }

}

