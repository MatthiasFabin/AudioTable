//
//  ViewController.swift
//  AudioTable
//
//  Created by Matthias Fabin on 07.04.2016.
//  Copyright © 2016 Matthias Fabin. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import MessageUI

class ViewController: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // Disable Stop/Play button when application launches
        stopButton.enabled = false
        playButton.enabled = false
        
        // Get the document directory. If fails, just skip the rest of the code
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else {
            
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            
            return
        }
        
        // Set the default audio file
    
        let audioFileURL = directoryURL.URLByAppendingPathComponent("MyAudioMemo.m4a")
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            
            // Define the recorder setting
            let recorderSetting: [String: AnyObject] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
            ]
            
            // Initiate and prepare the recorder
            audioRecorder = try AVAudioRecorder(URL: audioFileURL, settings: recorderSetting)
            audioRecorder?.delegate = self
            audioRecorder?.meteringEnabled = true
            audioRecorder?.prepareToRecord()
            
        } catch {
            print(error)
        }
    }
    
    @IBAction func play(sender: AnyObject) {
        if let recorder = audioRecorder {
            if !recorder.recording {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOfURL: recorder.url)
                    audioPlayer?.delegate = self
                    audioPlayer?.play()
                    playButton.setImage(UIImage(named: "playing"), forState: UIControlState.Selected)
                    playButton.selected = true
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        recordButton.setImage(UIImage(named: "record"), forState: UIControlState.Normal)
        recordButton.selected = false
        playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        playButton.selected = false
        
        stopButton.enabled = false
        playButton.enabled = true
        
        audioRecorder?.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }
    
    @IBAction func record(sender: AnyObject) {
        // Stop the audio player before recording
        if let player = audioPlayer {
            if player.playing {
                player.stop()
                playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
                playButton.selected = false
            }
        }
        
        if let recorder = audioRecorder {
            if !recorder.recording {
                let audioSession = AVAudioSession.sharedInstance()
                
                do {
                    try audioSession.setActive(true)
                    

                    
                    guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else {
                        
                        let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .Alert)
                        alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        presentViewController(alertMessage, animated: true, completion: nil)
                        
                        return
                    }
                
                    // Set the default audio file
                    
                    
                                        let format = NSDateFormatter()
                                        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
                                        let currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
                    
                    let audioFileURL = directoryURL.URLByAppendingPathComponent(currentFileName)
                    
                    // Setup audio session
                    let audioSession = AVAudioSession.sharedInstance()
                    
                    do {
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
                        
                        // Define the recorder setting
                        let recorderSetting: [String: AnyObject] = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100.0,
                            AVNumberOfChannelsKey: 2,
                            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
                        ]
                        
                        // Initiate and prepare the recorder
                        audioRecorder = try AVAudioRecorder(URL: audioFileURL, settings: recorderSetting)
                        audioRecorder?.delegate = self
                        audioRecorder?.meteringEnabled = true
                        audioRecorder?.prepareToRecord()
                        
                        
                        audioRecorder?.record()
                        recordButton.setImage(UIImage(named: "recording"), forState: UIControlState.Selected)
                        recordButton.selected = true
                        
                    } catch {
                        print(error)
                    }
                    // Start recording
                } catch {
                    print(error)
                }
                
            } else {
                // Pause recording
                recorder.pause()
                recordButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
                recordButton.selected = false
            }
        }
        
        stopButton.enabled = true
        playButton.enabled = false
    }
    
    
    // MARK: - AVAudioRecorderDelegate Methods
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "Finish Recording", message: "Successfully recorded the audio!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    // MARK: - AVAudioPlayerDelegate Methods
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        playButton.selected = false
        
        let alertMessage = UIAlertController(title: "Finish Playing", message: "Finish playing the recording!", preferredStyle: .Alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertMessage, animated: true, completion: nil)
    }
}