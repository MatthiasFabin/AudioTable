//
//  AudioTableViewController.swift
//  AudioTable
//
//  Created by Matthias Fabin on 07.04.2016.
//  Copyright © 2016 Matthias Fabin. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import MGSwipeTableCell
import MessageUI

class AudioTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var recordsToEdit:String?
    var recordings = [NSURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        listRecordings()
        
        tableView.registerNib(UINib(nibName: "RecordingCell", bundle: nil), forCellReuseIdentifier: "RecordingCell")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editSeque" {
            let destinationVC = segue.destinationViewController as! EditViewController
            destinationVC.fileName = self.recordsToEdit!
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordingCell", forIndexPath: indexPath) as! RecordingCell
        //let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! RecordingCell
        cell.recordingTitleLabel!.text = recordings[indexPath.row].lastPathComponent
        cell.cellDelegate = self
        cell.oldName = recordings[indexPath.row].lastPathComponent
        
        let a = MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.removeOldFileIfExist(cell.recordingTitleLabel!.text!)
            return true
        })
        
        let b = MGSwipeButton(title: "Rename", backgroundColor: UIColor.blueColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            cell.recordingTitleLabel.enabled = true
            cell.recordingTitleLabel.becomeFirstResponder()
            return true
        })
        
        let c = MGSwipeButton(title: "Share", backgroundColor: UIColor.blueColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            self.sendEmail(cell.recordingTitleLabel!.text!)
            
//            let defaultText = "Just checking in at "
//
//            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
//            let plistPath = paths.stringByAppendingPathComponent(cell.recordingTitleLabel!.text!)
//            
////            if let imageToShare = UIImage(named:
////                self.restaurantImages[indexPath.row]) {
//                let activityController = UIActivityViewController(activityItems:
//                    [defaultText], applicationActivities: nil)
//                self.presentViewController(activityController, animated: true,
//                    completion: nil)
////            }
            return true
        })
        
        let d = MGSwipeButton(title: "Edit", backgroundColor: UIColor.greenColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.recordsToEdit = cell.recordingTitleLabel!.text!
            self.performSegueWithIdentifier("editSeque", sender: nil)
            print("Convenience callback for swipe buttons!")
            return true
        })

        cell.rightButtons = [a, b, c, d]
        
        return cell
    }
    
    func listRecordings() {
        
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        do {
            let urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            self.recordings = urls.filter( { (name: NSURL) -> Bool in
                return name.lastPathComponent!.hasSuffix("m4a")
            })
            
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("something went wrong")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordings.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func removeOldFileIfExist(fileName: String) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0]
            let fileName = fileName
            let filePath = NSString(format:"%@/%@", dirPath, fileName) as String
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(filePath)
                    print("old image has been removed")
                    listRecordings()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                } catch {
                    print("an error during a removing")
                }
            }
        }
    }
    
    func renameFile(fileToRename: String, toName: String) {
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else {
            
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            
            return
        }
        
        let originPath = directoryURL.URLByAppendingPathComponent(fileToRename)
        let destinationPath = directoryURL.URLByAppendingPathComponent("\(toName).m4a")
        let manager = NSFileManager()
        do {
            try manager.moveItemAtURL(originPath, toURL: destinationPath)
            listRecordings()
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } catch {
            
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
    // Configure the cell...
    
    return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func sendEmail(fileName: String) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.delegate = self
        
        //Set the subject and message of the email
        mailComposer.setSubject("Voice Note")
        mailComposer.setMessageBody("my sound", isHTML: false)
        mailComposer.setToRecipients([""])
        
        if let docsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String {
            let fileManager = NSFileManager.defaultManager()
            let filecontent = fileManager.contentsAtPath(docsDir + "/" + fileName)
            mailComposer.addAttachmentData(filecontent!, mimeType: "audio/x-m4a", fileName: fileName)
        }
        
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
}


extension AudioTableViewController: RecordingCellDelgate, MFMessageComposeViewControllerDelegate {
    func  recordingCell(cell: RecordingCell, finishEditingName newName: String) {
        renameFile(cell.oldName, toName: newName)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}