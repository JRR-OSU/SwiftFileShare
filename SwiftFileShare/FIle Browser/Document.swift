//
//  Document.swift
//  SwiftFileShare
//
//  Created by Jon Reed on 3/15/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import UIKit
/// Class which simply is used to return contents of document file data
class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

