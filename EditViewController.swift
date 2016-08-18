//
//  EditViewController.swift
//  AudioTable
//
//  Created by Matthias Fabin on 05/05/16.
//  Copyright © 2016 Matthias Fabin. All rights reserved.
//

import UIKit
import AudioKit

class EditViewController: UIViewController {
    
    var player:AKAudioPlayer!
    var highPassFilter: AKHighPassFilter!
    var lowPassFilter: AKLowPassFilter!
    var parametricEQ1: AKParametricEQ!
    var parametricEQ2: AKParametricEQ!
    var parametricEQ3: AKParametricEQ!
    var parametricEQ4: AKParametricEQ!
    var parametricEQ5: AKParametricEQ!
    var parametricEQ6: AKParametricEQ!
    var highShelfFilter:  AKHighShelfFilter!
    var dynamicsProcessor: AKDynamicsProcessor!
    var dynamicsProcessor2: AKDynamicsProcessor!
    var peakLimiter: AKPeakLimiter!
    var fileName: String!
    var mixture: AKDryWetMixer!
    var gain: AKBooster!
    var plot: AKOutputWaveformPlot!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var bypassButton: UIButton!
    @IBOutlet weak var waveGraphFrame: UIView!
    
    @IBOutlet weak var gainSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Edit"
        configureAudioKit()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AudioKit.stop()
    }
    
    func configureAudioKit() {
            guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else {
                
                let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
                
                return
            }

            // Set the default audio file
            
            let audioFileURL = directoryURL.URLByAppendingPathComponent(self.fileName)
            
            
            
            if self.fileName != nil{
                
                // zadelkarowanie odtwarzacza po wczytaniu pliku z tabeli
                self.player = AKAudioPlayer(audioFileURL.path!)
                
                // ustawienie wzmocnienia przed wszystkimi efektami
                self.gain = AKBooster(self.player,gain: 0.5)

                self.setParameters()
                self.mixture = AKDryWetMixer(self.gain, self.peakLimiter, balance: 0)
                
                
                AudioKit.output = self.mixture
                AudioKit.start()
                self.gain.start()
                self.plot = AKOutputWaveformPlot(frame: self.waveGraphFrame.bounds)
                dispatch_async(dispatch_get_main_queue(), { 
                    self.view.addSubview(self.plot)
                })
            }
    }
    
    func setParameters() {
        self.highPassFilter = AKHighPassFilter(self.gain)
        self.highPassFilter.cutoffFrequency = 100
        
        parametricEQ1 = AKParametricEQ(highPassFilter)
        parametricEQ1.centerFrequency = 485
        parametricEQ1.q = 1
        parametricEQ1.gain = -1.5
        
        parametricEQ2 = AKParametricEQ(parametricEQ1)
        parametricEQ2.centerFrequency = 4000
        parametricEQ2.q = 1.4
        parametricEQ2.gain = -2.5
        
        parametricEQ3 = AKParametricEQ(parametricEQ2)
        parametricEQ3.centerFrequency = 8500
        parametricEQ3.q = 2.9
        parametricEQ3.gain = -3
        
        // pierwszy kompresor
        dynamicsProcessor = AKDynamicsProcessor(parametricEQ3)
        dynamicsProcessor.threshold = -14 // dB
        dynamicsProcessor.headRoom = 4 // dB - similar to 'ratio' on most compressors
        dynamicsProcessor.attackTime = 0.12 // secs
        dynamicsProcessor.releaseTime = 0.14 // secs
        dynamicsProcessor.expansionRatio = 1 // effectively bypassing the expansion by using ratio of 1
        dynamicsProcessor.expansionThreshold = 0 // rate
        dynamicsProcessor.masterGain = 1 // dB - makeup gain
        
        // drugi kompresor
        dynamicsProcessor2 = AKDynamicsProcessor(dynamicsProcessor)
        dynamicsProcessor2.threshold = -20 // dB
        dynamicsProcessor2.headRoom = 4 // dB - similar to 'ratio' on most compressors
        dynamicsProcessor2.attackTime = 0.08 // secs
        dynamicsProcessor2.releaseTime = 0.25 // secs
        dynamicsProcessor2.expansionRatio = 1 // effectively bypassing the expansion by using ratio of 1
        dynamicsProcessor2.expansionThreshold = 0 // rate
        dynamicsProcessor2.masterGain = 2 // dB - makeup gain
        
        // filtry wzmacniające
        
        parametricEQ4 = AKParametricEQ(dynamicsProcessor)
        parametricEQ4.centerFrequency = 120
        parametricEQ4.q = 2
        parametricEQ4.gain = 1
        
        parametricEQ5 = AKParametricEQ(parametricEQ4)
        parametricEQ5.centerFrequency = 1200
        parametricEQ5.q = 2.9
        parametricEQ5.gain = 1.5
        
        parametricEQ6 = AKParametricEQ( parametricEQ5)
        parametricEQ6.centerFrequency = 2000
        parametricEQ6.q = 1.4
        parametricEQ6.gain = 3
        
        highShelfFilter = AKHighShelfFilter(parametricEQ6)
        highShelfFilter.cutOffFrequency = 5000 // Hz
        highShelfFilter.gain = 3 // dB
        
        peakLimiter = AKPeakLimiter(highShelfFilter)
        peakLimiter.attackTime = 0.001 // seconds
        peakLimiter.decayTime  = 0.01  // seconds
        peakLimiter.preGain    = -2 // dB (-40 to 40)
    }
    
    @IBAction func play(sender: UIButton) {
       player.play()
    }
    
    @IBAction func stop(sender: UIButton) {
        player.stop()
    }
    
    @IBAction func process(sender: UIButton) {
        mixture.balance =  1
    }
    
    @IBAction func bypass(sender: UIButton) {
        mixture.balance =  0
    }
    
    @IBAction func gain(sender: UISlider) {
        gain.gain = Double (sender.value)
    }
}
