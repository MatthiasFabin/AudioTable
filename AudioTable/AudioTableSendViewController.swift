//
//  AudioTableSendViewController.swift
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

class AudioTableSendViewController: UITableViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MFMailComposeViewControllerDelegate {
    
    var recordsToEdit:String?
    var recordings = [NSURL]()
     var audioPlayer:AVAudioPlayer?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Library"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        if let player = audioPlayer {
            player.stop()
        }
    }
    
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
        
        let c = MGSwipeButton(title: "Share", backgroundColor: UIColor.greenColor(), callback: {
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
      
        cell.rightButtons = [a, b, c,]
        
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
        if let audioPlayer = audioPlayer where audioPlayer.playing && audioPlayer.url == self.recordings[indexPath.row] {
            audioPlayer.stop()
            self.audioPlayer = nil
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            self.audioPlayer = setupAudioPlayerWithFile(self.recordings[indexPath.row])
            self.audioPlayer?.play()
        }
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
    
    func setupAudioPlayerWithFile(url: NSURL) -> AVAudioPlayer?  {
        //1
        //        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        //        let url = NSURL.fileURLWithPath(path!)
        //
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        return audioPlayer
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
    
    func sendEmail(fileName: String) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        //Set the subject and message of the email
        mailComposer.setSubject("Speech Note")
        mailComposer.setMessageBody("Hi, this is what I recorded for you.", isHTML: false)
        mailComposer.setToRecipients([""])
        
       let docsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let fileManager = NSFileManager.defaultManager()
            let filecontent = fileManager.contentsAtPath(docsDir + "/" + fileName)
            mailComposer.addAttachmentData(filecontent!, mimeType: "audio/x-m4a", fileName: fileName)
            
        
        self.presentViewController(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
            dismissViewControllerAnimated(true, completion: nil)
    }
}
extension AudioTableSendViewController: RecordingCellDelgate {
    func  recordingCell(cell: RecordingCell, finishEditingName newName: String) {
        renameFile(cell.oldName, toName: newName)
    }

}