//
//  ConnectionsViewController.swift
//  SwiftFileShare
//
//  Created by Jon Reed on 3/29/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity

class ConnectionsViewController : UIViewController,  MCNearbyServiceBrowserDelegate, MCBrowserViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    /// Required coder initializer function for this object
    required init?(coder aDecoder: NSCoder) {
        mcManager = MCManager()
        super.init(coder: aDecoder)
    }
    
    /* UI buttons and text field outlets from the app storyboard */

    @IBOutlet weak var btnDisconnect: UIButton!
    

    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var swVisible: UISwitch!
    
    @IBOutlet weak var browseForDevices: UIButton!
    @IBOutlet weak var NBBrowse: UIButton!
  
    @IBOutlet weak var connectedDevices: UITableView!
    
    var mcManager : MCManager
    var _arrConnectedDevices = NSMutableArray.init()

    
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
   
    // Setup our multipeer connectivity manager
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    mcManager = appDelegate.mcManager!
    mcManager.connectionsViewController = self
    mcManager.setupPeerAndSessionWithDisplayName(name: UIDevice.current.name)
    mcManager.advertiseSelf(shouldAdvertise: swVisible.isOn)
    mcManager.advertiseNearBySelf(shouldNBAdvertise: swVisible.isOn)

    
    // Add an observer function for when a user connects
    NotificationCenter.default.addObserver(self, selector: #selector(peerDidChangeStateWithNotification(notif:)), name: NSNotification.Name(rawValue: "MCDidChangeStateNotification"), object: nil)

    // Setup delegates
    connectedDevices.delegate = self
    connectedDevices.dataSource = self
    txtName.delegate = self
    btnDisconnect.isEnabled = false
    connectedDevices.reloadData()

    }
    
    // Called when the function reappears to the user
    override func viewWillAppear(_ animated: Bool) {
        // Reset our array of connected devices
        if(!(mcManager._session?.connectedPeers == nil || mcManager._session?.connectedPeers.count == 0)){
            _arrConnectedDevices.removeAllObjects()
            for peer in (mcManager._session?.connectedPeers)!{
                _arrConnectedDevices.add(peer)
            }
        }
        DispatchQueue.main.async { // Reload the table on the main thread asynchronously
            self.connectedDevices.reloadData()
        }
    }
    
    // Setup text field for peer name adjustment
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mcManager._peerID = nil
        mcManager._session = nil
        mcManager._browser = nil
        
        if(swVisible.isOn){
            mcManager._advertiser?.stop()
        }
        mcManager._advertiser = nil
        mcManager.setupPeerAndSessionWithDisplayName(name: textField.text!)
        
        mcManager.setupMCBrowser()
        mcManager.advertiseSelf(shouldAdvertise: swVisible.isOn)
        return true
    }
    
    /* Implementation for functions which conform to the MultipeerConnectivity protocol */
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        mcManager._browser?.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        mcManager._browser?.dismiss(animated: true, completion: nil)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer! \(peerID)")
    }
    
    // If we lost a peer, reload the data of connected users
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if(!(mcManager._session?.connectedPeers == nil || mcManager._session?.connectedPeers.count == 0)){
            _arrConnectedDevices.removeAllObjects()
            for peer in (mcManager._session?.connectedPeers)!{
                _arrConnectedDevices.add(peer)
            }
        }
        DispatchQueue.main.async {
            self.connectedDevices.reloadData()
        }
        print("Lost peer! \(peerID)")
    }
    /// Function which handles updating the array on user change state
    @objc func peerDidChangeStateWithNotification(notif : Notification){
        var peerID = notif.userInfo!["peerID"] as! MCPeerID
        var state = notif.userInfo!["state"] as? Int
        if(state != MCSessionState.connecting.rawValue){
            if(state == MCSessionState.connected.rawValue){
             
                _arrConnectedDevices.add(peerID)
                DispatchQueue.main.async {
                    self.connectedDevices.reloadData()
                    self.btnDisconnect.isEnabled = true
                }
            }
        }
        else if(state == MCSessionState.notConnected.rawValue){
            _arrConnectedDevices.remove(peerID)
        }
        DispatchQueue.main.async {
            self.connectedDevices.reloadData()
        }
    }
    

    // Function which opens an MC browser to browse for devices, tied to an outlet in the storyboard
    @IBAction func browseForDevices(_ sender: Any) {
        mcManager.setupMCBrowser()
        mcManager._browser?.delegate = self
        self.present(mcManager._browser!, animated: true, completion: nil)
        
    }
    /// Outlet function which will change our visibility to peers based on the toggle switch
    @IBAction func toggleVisibility(_ sender: Any) {
        mcManager.advertiseSelf(shouldAdvertise: swVisible.isOn)
    }
    /// Outlet function called when user taps on disconnect
    @IBAction func disconnect(_ sender: Any) {
        mcManager._session?.disconnect()
        txtName.isEnabled = true
        _arrConnectedDevices.removeAllObjects()
        DispatchQueue.main.async {
            self.connectedDevices.reloadData()
            self.btnDisconnect.isEnabled = false
        }
        btnDisconnect.isEnabled = false
        
    }
    
    /* UI Code for our table view of connected users */
    func numberOfSections(in connectedDevices: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ connectedDevices: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Connected Peers"
    }
    
    func tableView(_ connectedDevices: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(_arrConnectedDevices.count)
        return _arrConnectedDevices.count
    }
    
    // Required function for table view to format and initalize cells
    func tableView(_ connectedDevices: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = connectedDevices.dequeueReusableCell(withIdentifier: "CellIdentifier")
        if(cell == nil){
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "CellIdentifier")
        }

        var peerID = _arrConnectedDevices[indexPath.row] as! MCPeerID
        
      
        cell!.textLabel?.text = peerID.displayName
        
        return cell!
    }
    
    func tableView(_ connectedDevices: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}
