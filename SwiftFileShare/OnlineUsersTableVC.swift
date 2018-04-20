//
//  OnlineUsersVC.swift
//  SwiftChat
//
//  Created by Jon Reed on 2/25/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//


import UIKit
import Firebase

/// Class which organizes and displays users that are currently online
class OnlineUsersTableVC: UITableViewController {
    
    // Cell reference ID
    let cellId = "cellId"
    
    var users = [User]()
    
    // Called when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up nav bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        self.tabBarController?.navigationItem.title = "Online Users"
        
        // Register each User cell in the table view
        tableView.register(UserTableCell.self, forCellReuseIdentifier: cellId)

        // Populate the table view
        fetchUsers()
    }
    
    /// When the view reappears change the nav bar title back
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Online Users"
    }

    /// Function which sets up a firebase observer on user attribute add or modification
    func fetchUsers() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                // Insert online users at the front of the table
                if(user.online == "Online"){
                    self.users.insert(user, at: 0)
                }
                else{ // Add offline users to the end
                    self.users.append(user)
                }
                
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
                    }
                }
            
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
    
    /* Apple specific table view formatting */
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserTableCell
        
        let user = users[indexPath.row]
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        if(user.id == uid){
            cell.textLabel?.text = user.name! + " (Me) | Status: " + user.online!
        }
        else{
            cell.textLabel?.text = user.name! + " | Status: " + user.online!
        }
        cell.detailTextLabel?.text = user.email
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
