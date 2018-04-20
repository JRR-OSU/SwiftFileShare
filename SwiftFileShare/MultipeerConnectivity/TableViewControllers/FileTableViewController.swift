//
//  FileTableViewController.swift
//  SwiftFileShare
//
//  Created by Jon Reed on 3/27/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import Foundation
import Firebase
import MultipeerConnectivity
import UIKit

/// Class which handles database connections and requesting/sending files via the UI
class FileTableViewController : UITableViewController{
    

    // Class level variables
    var DocBrowserView : DocumentBrowserViewController? // Reference to instantiate documents view controller
    var docFiles : NSMutableArray?
    // Cell reference ID
    let cellId = "cellId"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup our tab bar
        let tabBarFirstImage = UIImage(named: "Document")
        self.tabBarController?.tabBar.items?[0].image = tabBarFirstImage
        let tabBarSecondImage = UIImage(named: "users_icon")
        self.tabBarController?.tabBar.items?[1].image = tabBarSecondImage
        
        // Set up our nav bar
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentDocView))
        navigationItem.rightBarButtonItem = addButton
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))


        // Populate the table view
            // copySameFilesToDocDirIfNeeded()
                docFiles = getAllDocDirFiles() // Parse all files in the Documents folder into an array
                updateUserFiles()
        
        fetchUsers()
        
        // Update reference to this class in the MCManager class
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.mcManager?.FileTableviewController = self


        

        checkIfUserIsLoggedIn()

        // Register each User cell in the table view
        tableView.register(UserTableCell.self, forCellReuseIdentifier: cellId)
    
    }
    
    // Called when the view appears. Refresh our file list
    override func viewWillAppear(_ animated: Bool) {
        
        updateUserFiles()
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                _ = [User(dictionary: dictionary)]
             
                // Insert online users at the front of the table
                

                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)


    }
    
    /// Function which sets up a firebase observer on user attribute add or modification
    func fetchUsers() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key

                // For this we insert all users not just the online ones (we want to see files for every single user)
                    self.users.insert(user, at: 0)

                // Reload the table asynchronously
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
        
        FIRDatabase.database().reference().child("users").observe(.childChanged, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                
                for u in self.users{
                    if(u.id == user.id){
                        u.online = user.online
                        u.files = user.files
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
        
        
    }
    
    /// Function which will copy sample text files from the bundle to the documents folder on app start
    func copySameFilesToDocDirIfNeeded(){
        _ = documentsDirectory
        
        let file1Path = documentsDirectory.appendingPathComponent("sample_file1.txt")
        
        let file2Path = documentsDirectory.appendingPathComponent("sample_file2.txt")
        let fileManager = FileManager.default
        var _: Error?
        if (!fileManager.fileExists(atPath: file1Path.relativeString) || !fileManager.fileExists(atPath: file2Path.relativeString)){
            do{
                let path = Bundle.main.path(forResource: "sample_file1", ofType: "txt")
                let resource = URL(fileURLWithPath: path!)
                try fileManager.copyItem(at: resource, to: file1Path)
                print("Copied file 1 to \(file1Path.relativeString)")
            }
            catch {
                print(error.localizedDescription)
            }
            do{
                let path = Bundle.main.path(forResource: "sample_file2", ofType: "txt")
                let resource = URL(fileURLWithPath: path!)
                try fileManager.copyItem(at: resource, to: file2Path)
                print("Copied file 2 to \(file2Path.relativeString)")
            }
                
            catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    /* Apple specific table view formatting */
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = users[section].files?.count
        if(count == nil || count == 0){
           return 0
            
        }
        return count!
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    // Make each table view section header each user's name
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return users[section].name
        
    }
    
    /// Function which will determine the cell information at each indexPath of the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserTableCell
        
        let user = users[indexPath.section]
        _ = FIRAuth.auth()?.currentUser?.uid
        
        
          //  cell.textLabel?.text = user.name! + " (Me) | Status: " + user.online!
        if(user.files?[indexPath.row] == nil){
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
        cell.textLabel?.text = user.files?[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    /* Code which handles requesting/sending files */
    var selectedFile : String?
    var selectedRow : Int?
    var documentsDirectory: URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    /// Function called when a table cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Select our peer
        let selectedUser = users[indexPath.section]
        var selectedPeer : MCPeerID?
        var selectedFile = selectedUser.files![indexPath.row]
        var isSelfUser = false
        let FIREmail = FIRAuth.auth()?.currentUser?.email
        if(selectedUser.email?.lowercased() == FIREmail){
            selectedFile = docFiles![indexPath.row] as! String
            isSelfUser = true // If the user is ourself, we will be sending a selected file
        }
        else{
            if(appDelegate.mcManager!._session != nil){
            for peer : MCPeerID in appDelegate.mcManager!._session!.connectedPeers {
                print(peer.displayName)
                if users[indexPath.section].name?.lowercased().range(of: peer.displayName.lowercased() ) != nil {
                    selectedPeer = peer
                    isSelfUser = false
                    break
                }
            }
            }
                else{
                    let alert = UIAlertController.init(title: "Not connected to other peers", message: "Connect to other peers to send this file", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    present(alert, animated: true)
                    return
                }
         
        }
        
        if(isSelfUser){ // If the user is ourself, we will be sending the file at the selected cell
        let confirmSending = UIAlertController(title: "Send to peer", message: "Choose a peer to send this file to", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if((appDelegate.mcManager?._session?.connectedPeers != nil && (appDelegate.mcManager?._session?.connectedPeers.count)! > 0)){
            for peer : MCPeerID in appDelegate.mcManager!._session!.connectedPeers {
                confirmSending.addAction(UIAlertAction(title: peer.displayName, style: UIAlertActionStyle.default, handler: {action in
                    self.sendFile(p: peer, isSelfUser: true, indexPath: indexPath)})) // Send the file to the pper
            }
            
            confirmSending.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            present(confirmSending, animated: true)
            self.selectedFile = (docFiles?[indexPath.row] as! String)
            selectedRow = indexPath.row
        }
        else{ // If we are not connected to peers, present an alert
            let alert = UIAlertController.init(title: "Not connected to other peers", message: "Connect to other peers to send this file", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true)
        }
        }
        else if(selectedPeer != nil && !isSelfUser && (appDelegate.mcManager?._session?.connectedPeers != nil && (appDelegate.mcManager?._session?.connectedPeers.count)! > 0)){
            
            // This alert behavior I could not get working correctly so I had to comment it out
//            let alert = UIAlertController.init(title: "Requested file", message: "\(indexPath.row) from \(indexPath.section)", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
//            present(alert, animated: true)
            sendFile(p: selectedPeer!, isSelfUser: false, indexPath: indexPath)
        }
        else{
            let alert = UIAlertController.init(title: "Not connected to this peer", message: "Connect to other peers to request this file", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    /// Function which handles sending of file or file request to specified peer
    func sendFile(p : MCPeerID, isSelfUser : Bool, indexPath: IndexPath){

        // If the user is our device do the following
        if(isSelfUser){
            var f = selectedFile?.replacingOccurrences(of: "file://", with: "")
            f = f?.removingPercentEncoding
            let filePath = URL(fileURLWithPath: f!, relativeTo: documentsDirectory)
            let fileName = filePath.lastPathComponent // Parse the filename so it is humanly readable
        let name = appDelegate.mcManager?._peerID?.displayName
        
            _ = "\(name)_\(fileName)"
        //let resourceURL = URL(fileURLWithPath: String(filePath)).absoluteURL
            _ = self.appDelegate.mcManager?._session?.connectedPeers.index(of: p)
        var data = Data()
        do {
            data = try Data(contentsOf: filePath , options: .alwaysMapped) // Write the file to a data object (binary)
        } catch let error {
            let alert = UIAlertController.init(title: "Error during send", message: "\(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.cancel, handler: nil))
            if(self.presentedViewController == nil){
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.dismiss(animated: true, completion: nil)
                self.present(alert, animated: true, completion: nil)
                print("parse error: \(error.localizedDescription)")
            }

               return
        }
            f = name! + " " + f!
            let file = MCManager.file.init(peer: p.displayName, name: fileName, localPath: URL.init(string: ""), d: data, isRequest: false) // Encapsulate the file in a data struct
        
        
            let archived = file.serialize() // Serialize the file struct for transmission
        
        
  
            do{
                try self.appDelegate.mcManager?._session?.send(archived!, toPeers: [p], with: MCSessionSendDataMode(rawValue: 0)!) // Send the encoded payload
                
                let alert = UIAlertController.init(title: "File sent successfully", message: "Well done.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Great!", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true)
                
                DispatchQueue.main.async {
                self.docFiles![self.selectedRow!] = self.selectedFile
                self.tableView.performSelector(onMainThread: #selector(self.tableView.reloadData), with: nil, waitUntilDone: false)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        // Otherwise we're sending a request payload for a file
        else{
            _ = self.appDelegate.mcManager?._session?.connectedPeers.index(of: p)
            let data = Data()
    
            // Instantiate a file struct for encapsulation, except this time make it a request for a specific file
            let file = MCManager.file.init(peer: p.displayName, name: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!, localPath: URL.init(string: ""), d: data, isRequest: true)
            
            
            let archived = file.serialize() // Serialize the request for transmission
            do{
                try self.appDelegate.mcManager?._session?.send(archived!, toPeers: [p], with: MCSessionSendDataMode(rawValue: 0)!) // Send the transmission
            }
            catch{
                print(error.localizedDescription)
            }
            
           
            let alert = UIAlertController.init(title: "Requested file: " + file.name, message: "Please wait while the other peer responds to the request", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {action in self.sendRequestPayload(d: archived!, peers: [p])}))
                    self.present(alert, animated: true)
        
                   // self.docFiles![self.selectedRow!] = self.selectedFile as Any
                     DispatchQueue.main.async {
                    self.tableView.performSelector(onMainThread: #selector(self.tableView.reloadData), with: nil, waitUntilDone: false)
                }
                    
               
            }
        }
    
    /* Unused function for seperate payload request */
    func sendRequestPayload(d : Data, peers : [MCPeerID]){

    }
    
    /// Function called when user taps on logout
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            // fetchUserAndSetupNavBarTitle()
        }
    }
    
    /// Function to update the user's files in the database by parsing the documents directory
    @objc func updateUserFiles() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let allFiles = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        var filesString = [String]()
        
        for file in allFiles{
            filesString.append(file.lastPathComponent)
        }
        let values = ["files" : filesString]
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).child("files").removeValue()
        FIRDatabase.database().reference().child("users").child(uid).updateChildValues(values)

        
    }
    /// Function which handles logout procedure via Firebase
    @objc func handleLogout() {
        
        let values = ["online": "Offline"]
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).updateChildValues(values)
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Called when user taps the + icon. A document browser window for previewing documents is brought up. To exit, tap on + again.
    @objc func presentDocView (){
        DocBrowserView = DocumentBrowserViewController()
        DocBrowserView?.FileTableView = self
        self.navigationController?.present(DocBrowserView!, animated: true, completion: nil)
    }
    
    /// Function to get all files in the documents directory, returns an NSMutableArray
    func getAllDocDirFiles() -> NSMutableArray{
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let allFiles = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        var arr = [String]()
        for file in allFiles{
            arr.append(file.lastPathComponent)
        }

        let ret = NSMutableArray.init(array: arr)
        return ret
    }
    
}
