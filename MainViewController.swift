//
//  MainViewController.swift
//  AudioTable
//
//  Created by Matthias Fabin on 09.05.2016.
//  Copyright © 2016 Matthias Fabin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // utworzenie 3 przycisków menu głównego, każde przekierowywuje do nowej sceny

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "RESpeech"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
