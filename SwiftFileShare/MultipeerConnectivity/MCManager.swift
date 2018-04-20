//
//  MCManager.swift
//  SwiftFileShare
//
//  Created by Jon Reed on 3/29/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// Class object which handles and manages our peer to peer connections
class MCManager : NSObject, MCSessionDelegate{
    
    /// Required initializer
    override init() {
            super.init()
            _peerID = nil;
            _session = nil;
            _browser = nil;
            _advertiser = nil;
            _nbBrowser = nil;
            _nbAdver = nil;
        
    }
    /* Class level variables */
    var FileTableviewController : FileTableViewController?
    var connectionsViewController : ConnectionsViewController?
    var _peerID : MCPeerID?;
    var _session : MCSession?;
    var _browser : MCBrowserViewController?;
    var _advertiser : MCAdvertiserAssistant?;
    var _nbBrowser : MCNearbyServiceBrowser?;
    var _nbAdver : MCNearbyServiceAdvertiser?;
    
    // File struct object for our files in transmission. Able to be serialized for encode on transmit and decode on recieve
    struct file : Serializable {
        func serialize() -> Data? {
            let encoder = JSONEncoder()
            return try? encoder.encode(self)
        }
        
        var peer : String
        var name : String
        var localPath : URL?
        var d : Data?
        var isRequest : Bool?
        
        static func archive(f:file) -> Data {
            var fw = f
            return Data(bytes: &fw, count: MemoryLayout<file>.stride)
        }
        
        static func unarchive(d:Data) -> file {
            guard d.count == MemoryLayout<file>.stride else {
                fatalError("Fatal error")
            }
            
            var w:file?
            d.withUnsafeBytes({(bytes: UnsafePointer<file>)->Void in
                w = UnsafePointer<file>(bytes).pointee
            })
            return w!
        }
        
        
    }

    var receivedFiles : [file] = [file].init()

    /* Functions implmented to conform to multipeer connectivity protocol */
    
    /// Called when the user changes state, update the connections table
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        var dict : NSDictionary
        dict = ["peerID" : peerID, "state" : state.rawValue]

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MCDidChangeStateNotification"), object: nil, userInfo: dict as? [AnyHashable : Any])
        if((connectionsViewController) != nil && (connectionsViewController?.connectedDevices) != nil){
            connectionsViewController?.connectedDevices.reloadData()
        }
        
    }
    
    /// Function which handles the sending of data
    func sendFile(p : MCPeerID, fileName : String){
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let allFiles = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        // Get all files in the doc directory
        var selectedFile : URL?
        for url in allFiles{
            if(url.relativePath.lowercased().range(of: fileName.lowercased()) != nil){
                selectedFile = url // Find the file that was selected
            }
        }
        print(fileName)
        print(selectedFile)
        var f = selectedFile?.relativePath.replacingOccurrences(of: "file://", with: "")
        f = f?.removingPercentEncoding
        f = p.displayName + " " + f!


        // Encode file data into data object
        var data = Data()
        do {
            data = try Data(contentsOf: selectedFile! , options: .alwaysMapped)
        } catch let error {
            let alert = UIAlertController.init(title: "Error during send", message: "\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.cancel, handler: nil))
            if(FileTableviewController?.presentedViewController == nil){
                FileTableviewController?.present(alert, animated: true, completion: nil)
            }
            else{
                FileTableviewController?.dismiss(animated: true, completion: nil)
                FileTableviewController?.present(alert, animated: true, completion: nil)
            print("parse error: \(error.localizedDescription)")
                return
            }
        }
        // Encapsulate the data object and serialize for transmission
        let file = MCManager.file.init(peer: p.displayName, name: f!, localPath: URL.init(string: ""), d: data, isRequest: false)
        let archived = file.serialize()
            do{
                try self._session?.send(archived!, toPeers: [p], with: MCSessionSendDataMode(rawValue: 0)!)
                
                let alert = UIAlertController.init(title: "File sent successfully", message: "Well done.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Great!", style: UIAlertActionStyle.cancel, handler: nil))
                self.FileTableviewController?.present(alert, animated: true)
            }
            catch {
                print(error.localizedDescription)
            }
        
        DispatchQueue.main.async {
            self.FileTableviewController?.tableView.reloadData()
        }
    }
    
    /// Function called when data is received from a peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        var dict : NSDictionary
        dict = ["data" : data, "peerID" : peerID] // Parse the data into a dicctionary
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MCDidReceiveDataNotification"), object: nil, userInfo: dict as! [AnyHashable : Any]) // Post a notification for the observer function
        
        // Unarchive the serialized data
        var data_unarchived : file
        let decoder = JSONDecoder.init()
        do{ // Decode the file
            data_unarchived = try decoder.decode(file.self, from: data)
            if(data_unarchived.isRequest)!{ // If a file was requested, get the file we need to send to the other user
               let alert = UIAlertController(title: "Peer: \(peerID.displayName) has requested a file", message: "Send: \(data_unarchived.name) to them?", preferredStyle: .alert)
                alert.addAction((UIAlertAction(title: "Send", style: .default, handler: {action in
                    self.sendFile(p: peerID, fileName: data_unarchived.name)})))
                alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: nil)))
                FileTableviewController?.present(alert, animated: true, completion: nil)
                return
            }
            let newFile = file.init(peer: peerID.displayName, name: "\(data_unarchived.name)", localPath: data_unarchived.localPath, d: data_unarchived.d, isRequest: false)
            
            receivedFiles.append(newFile)
            
            if(newFile != nil){ // If we have a new file object
                let fileManager = FileManager.default
                do {
                    let url = URL(fileURLWithPath: newFile.name)
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(url.lastPathComponent) // Obtain path to documents folder
                    try newFile.d?.write(to: fileURL) // Parse the binary stream and write the file to the documents folder

                    let name = url.lastPathComponent
                    let alert = UIAlertController(title: "\(name) successfully written to documents folder", message: nil, preferredStyle: .alert)
                    alert.addAction((UIAlertAction(title: "Great!", style: .cancel, handler: nil)))
                    DispatchQueue.main.async {
                        self.FileTableviewController?.tableView.reloadData()
                    } /* UI Code to handle alert controllers */
                    if(FileTableviewController?.presentedViewController == nil){
                        FileTableviewController?.present(alert, animated: true, completion: nil)
                    }
                    else{
                        FileTableviewController?.dismiss(animated: true, completion: nil)
                        FileTableviewController?.present(alert, animated: true, completion: nil)
                    }
                    
                }
                catch{ /* UI Code to handle alert controllers */
                    let alert = UIAlertController(title: "File couldn't be written to this device", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction((UIAlertAction(title: "Try again", style: .cancel, handler: nil)))
                    if(FileTableviewController?.presentedViewController == nil){
                        FileTableviewController?.present(alert, animated: true, completion: nil)
                    }
                    else{
                        FileTableviewController?.dismiss(animated: true, completion: nil)
                        FileTableviewController?.present(alert, animated: true, completion: nil)
                    }
                    print(error.localizedDescription)
                    return
                }
            }
        }
        catch{
            print("\n\n\nerror decoding the data")
        }
       
    }
    
    // Required implementation to conform to protocol
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
       print(stream)
    }
    
    /* Function called when a file is transmistted... seemingly unusable with iOS 11 file system */
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        var dict : NSDictionary
        dict = ["resourceName" : resourceName, "peerID" : peerID, "progress" : progress]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MCDidStartReceivingResourceNotification"), object: nil, userInfo: dict as? [AnyHashable : Any])
        DispatchQueue.main.async(execute: {() -> Void in
//            progress.addObserver(self as NSObject, forKeyPath: "fractionCompleted", options: .new, context: nil)
        })
    }
    /* Function called when a file is fully received ... seemingly unusable with iOS 11 file system */
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        var dict : NSDictionary
        dict = ["resourceName" : resourceName, "peerID" : peerID, "localURL" :localURL as Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MCDidChangeStateNotification"), object: nil, userInfo: dict as? [AnyHashable : Any])
        let newFile = file.init(peer: peerID.displayName, name: resourceName, localPath: (localURL)!, d: nil, isRequest: false)
        receivedFiles.append(newFile)
        

        
    }
 /* Other functions to conform to protocol */
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }

    func setupPeerAndSessionWithDisplayName(name : String){
        _peerID = MCPeerID.init(displayName: name)
        _session = MCSession(peer: _peerID!, securityIdentity: nil, encryptionPreference: .required) // Set required encryption
        _session?.delegate = self
        
    }
    
    func setupNBBrowser(){
        _nbBrowser = MCNearbyServiceBrowser.init(peer: _peerID!, serviceType: "chat-nb")
    }
    
    func setupMCBrowser(){
        _browser = MCBrowserViewController.init(serviceType: "chat-files", session: _session!)
    }
    
    func advertiseNearBySelf(shouldNBAdvertise : Bool){
        if(shouldNBAdvertise){
            _nbAdver = MCNearbyServiceAdvertiser.init(peer: _peerID!, discoveryInfo: nil, serviceType: "chat-nb")
            _nbAdver!.startAdvertisingPeer()
        }
        else{
            _nbAdver!.stopAdvertisingPeer()
            _nbAdver = nil
        }
    }
    
    func advertiseSelf(shouldAdvertise:Bool){
        if(shouldAdvertise){
            _advertiser = MCAdvertiserAssistant.init(serviceType: "chat-files", discoveryInfo: nil, session: _session!)
            _advertiser?.start()
        }
        else{
            _advertiser!.stop()
            _advertiser = nil
        }
    }
    
   
}

protocol Serializable : Codable {
    func serialize() -> Data?
}


