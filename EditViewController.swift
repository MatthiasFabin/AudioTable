//
//  EditViewController.swift
//  AudioTable
//
//  Created by Błażej Chwiećko on 05/05/16.
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
    var dynamicsProcessor: AKDynamicsProcessor!
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
        
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else {
            
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            
            return
        }
        
        // Set the default audio file
        
        let audioFileURL = directoryURL.URLByAppendingPathComponent(fileName)

    
        
      if fileName != nil{
        
            player = AKAudioPlayer(audioFileURL.path!)
            gain = AKBooster(player,gain: 0.5)
        
            //let mixer = AKMixer(player)
            highPassFilter = AKHighPassFilter(gain)
            highPassFilter.cutoffFrequency = 100
            
            lowPassFilter = AKLowPassFilter(highPassFilter)
            lowPassFilter.cutoffFrequency = 16000
            parametricEQ1 = AKParametricEQ(lowPassFilter)
            parametricEQ1.centerFrequency = 445 // Hz
            parametricEQ1.q = 0.5 // Hz
            parametricEQ1.gain = -4 // dB
            parametricEQ2 = AKParametricEQ(parametricEQ1)
            parametricEQ2.centerFrequency = 3500 // Hz
            parametricEQ2.q = 0.7 // Hz
            parametricEQ2.gain = -6 // dB
            
            dynamicsProcessor = AKDynamicsProcessor(parametricEQ2)
            dynamicsProcessor.threshold = -40 // dB
            dynamicsProcessor.headRoom = 4 // dB - similar to 'ratio' on most compressors
            dynamicsProcessor.attackTime = 0.1 // secs
            dynamicsProcessor.releaseTime = 0.5 // secs
            dynamicsProcessor.expansionRatio = 1 // effectively bypassing the expansion by using ratio of 1
            dynamicsProcessor.expansionThreshold = 0 // rate
            dynamicsProcessor.masterGain = 10 // dB - makeup gain
            
            peakLimiter = AKPeakLimiter(dynamicsProcessor)
            peakLimiter.attackTime = 0.001 // seconds
            peakLimiter.decayTime  = 0.01  // seconds
            peakLimiter.preGain    = 5 // dB (-40 to 40)
        
        
            mixture = AKDryWetMixer(gain, peakLimiter, balance: 0)

        
            AudioKit.output = mixture
            AudioKit.start()
            gain.start()
        plot = AKOutputWaveformPlot(frame: waveGraphFrame.bounds)
view.addSubview(plot)

        // Do any additional setup after loading the view.
    }

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
