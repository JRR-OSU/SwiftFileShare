//
//  DocumentViewController.swift
//  SwiftFileShare
//
//  Created by Jon Reed on 3/15/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import UIKit
import QuickLook

/// Class which handles previewing documents with our DocumentBrowserController
class DocumentViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate{
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = self.document?.fileURL
        return  url! as QLPreviewItem
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                
                
                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                
                let quicklook = QLPreviewController()
                quicklook.dataSource = self
                
                self.present(quicklook, animated: true, completion: nil)
                
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}
