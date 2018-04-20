//
//  User.swift
//  SwiftChat
//
//  Created by Jon Reed on 1/25/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import UIKit

/// Data object to store info for each user
class User: NSObject {
    // Class variables for each user
    var id: String?
    var name: String?
    var email: String?
    var files: [String]?
    // Online status, set to either string 'Online' or string 'Offline'
    var online: String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.online = dictionary["online"] as? String
        self.files = dictionary["files"] as? [String]
    }
}
