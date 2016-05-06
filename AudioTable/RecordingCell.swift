//
//  RecordingCell.swift
//  AudioTable
//
//  Created by Błażej Chwiećko on 05/05/16.
//  Copyright © 2016 Matthias Fabin. All rights reserved.
//

import UIKit
import MGSwipeTableCell

protocol RecordingCellDelgate {
    func recordingCell(cell: RecordingCell, finishEditingName newName: String)
}

class RecordingCell: MGSwipeTableCell {

    @IBOutlet weak var recordingTitleLabel: UITextField!
    var oldName: String!
    var cellDelegate: RecordingCellDelgate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func hideKeyboard(sender: AnyObject?) {
        recordingTitleLabel.resignFirstResponder()
        cellDelegate.recordingCell(self, finishEditingName: recordingTitleLabel!.text!)
        recordingTitleLabel.enabled = false
    }
    
}

extension RecordingCell: UITextFieldDelegate {

}
