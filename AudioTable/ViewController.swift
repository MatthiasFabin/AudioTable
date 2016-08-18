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
    
    // Utworzenie przycisków
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var meterTimer = NSTimer()
    var timer = NSTimer()
    var timer2 = NSTimer()
    var counter = 00.00
    
    // deklracja narzędzi do odtwarzania i nagrywania dźwięku
    
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // przyciski play i stop nie są aktywne po uruchomieniu aplikacji, stają się aktywne dopiero po nagraniu
        stopButton.enabled = false
        playButton.enabled = false
        
        //wprowadzenie funkcji wyswietlajacej poziom nagrania
        
        meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateValue(_:)), userInfo: nil, repeats: true)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.updateCounter), userInfo: nil, repeats: true)
        
         timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.updateCounter2), userInfo: nil, repeats: true)
        
        timeLabel.text = String(counter)
    }
    
    func updateCounter() {
         if let recorder = self.audioRecorder  {
            if recorder.recording{
                counter+=0.1
       timeLabel.text = String(counter.roundToPlaces(1) )
    }
         } else {
           timeLabel.text = " "
        }
    }
    
    func updateCounter2() {
        if let player = self.audioPlayer {
            if player.playing{
                counter+=0.1
                timeLabel.text = String(counter.roundToPlaces(1) )
            }
        }
    }

    
    func updateValue(any: AnyObject) {
        if let audioRecorder = audioRecorder {
            audioRecorder.updateMeters()
            dispatch_async(dispatch_get_main_queue(), {
                let peakPower = Double(audioRecorder.peakPowerForChannel(0))
                
                if let recorder = self.audioRecorder {
                    if recorder.recording{
               self.meterLabel.text = "\(peakPower.roundToPlaces(1))" + " dB"
                        
                    }
                } else {

                self.meterLabel.text = " "
                }
            
            })
        }
    }
    
    // Zdefiniowanie nazwy wyświetlanej w pasku nawigacji
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Record"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // wskazanie katalogu dokumentów, jeżeli nie ma do niego dostępu, pojawia się błąd
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else {
            
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            
            return
        }
        
        // utworzenie domyślnego pliku audio
        
        let audioFileURL = directoryURL.URLByAppendingPathComponent("MyAudioMemo.m4a")
        
        // Ustawienie sesji audio
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            
            // definiowanie parametrów nagrywania
            let recorderSetting: [String: AnyObject] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
            ]
            
            // inicjowanie i przygotowywanie rejestratora
            audioRecorder = try AVAudioRecorder(URL: audioFileURL, settings: recorderSetting)
            audioRecorder?.delegate = self
            audioRecorder?.meteringEnabled = true
            audioRecorder?.prepareToRecord()
            
        } catch {
            print(error)
        }
    }
    
    // zdefiniowanie funkcji po wciśnięciu odtwarzania (jeżeli rejestrator nie nagrywa, to plik audio jest odtwarzany). System zapisuje też informację, że plik jest odtwarzany a przycisk zaznaczony
    @IBAction func play(sender: AnyObject) {
        if let recorder = audioRecorder {
            if !recorder.recording {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOfURL: recorder.url)
                    audioPlayer?.delegate = self
                    audioPlayer?.play()
                    playButton.selected = true
                    stopButton.enabled = true
                    counter = 0
                   
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // zdefiniowanie funkcji po wciśnięciu odtwarzania
    @IBAction func stop(sender: AnyObject) {
        recordButton.selected = false
        playButton.selected = false
        
        stopButton.enabled = false
        playButton.enabled = true
        recordButton.enabled = true
        
        audioRecorder?.stop()
        audioPlayer?.stop()
        counter = 0
        timeLabel.text = "0"
    }
    // zdefiniowanie funkcji po wciśnięciu nagrywania
    @IBAction func record(sender: AnyObject) {
        // wyłączenie odtwarzania pliku, jeżeli jest odtwarzany
        if let player = audioPlayer {
            if player.playing {
                player.stop()
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
                    
                    // ustawienie domyślnego pliku audio
                    
                    
                    let format = NSDateFormatter()
                    format.dateFormat="yyyy-MM-dd-HH-mm-ss"
                    let currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
                    
                    let audioFileURL = directoryURL.URLByAppendingPathComponent(currentFileName)
                    
                    // Setup audio session
                    let audioSession = AVAudioSession.sharedInstance()
                    
                    do {
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
                        
                        // zdefiniowanie parametrów nagrywania
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
                        recordButton.selected = true
                        counter = 0
                      
                        
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
            self.meterLabel.text = " "

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

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}