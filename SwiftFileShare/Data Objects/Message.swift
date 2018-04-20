//
//  Message.swift
//  SwiftChat
//
//  Created by Jon Reed on 1/25/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import UIKit
import Firebase

/// Data object for each message payload
class Message: NSObject {

    // Class variables to determine message to and from ID nums, text, and timestamp
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    
    /// Constructor which defines each message as a dictionary (fromId, toId, text, timestamp)
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.toId = dictionary["toId"] as? String
        self.text = dictionary["text"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
    }
    
    /// Function which returns chat partner ID as a string
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
}
