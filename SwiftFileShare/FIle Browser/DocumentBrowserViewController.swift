//
//  DocumentBrowserViewController.swift
//  SwiftFileShare
//
//  Created by Jon Reed on 3/15/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//

import UIKit
import QuickLook

/// Class for our iOS 11 UI document browser
class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate{
    
    
    var FileTableView : FileTableViewController?
    
    @IBAction func Home(_ sender: Any) {
        self.present(FileTableView!, animated: true, completion: nil)
    }
    
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = self.document?.fileURL
        return  url! as QLPreviewItem
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
        var document: UIDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        allowsDocumentCreation = true
   
        allowsPickingMultipleItems = true
        self.browserUserInterfaceStyle = .dark
        self.view.tintColor = .red
        
       
        
        
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    
    /// Workaround function which will dismiss the controller if we "create" a document
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }

    
    // MARK: Document Presentation
    
    /// Function called when user taps on a document in the browser. Pulls up a quick look controller to preview it.
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        self.document = Document(fileURL: documentURL)
        
        let quicklook = QLPreviewController()
        quicklook.dataSource = self
        
        self.present(quicklook, animated: true, completion: nil)
     }
}

