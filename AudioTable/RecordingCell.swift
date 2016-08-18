//
//  RecordingCell.swift
//  AudioTable
//
//  Created by Matthias Fabin on 05/05/16.
//  Copyright © 2016 Matthias Fabin. All rights reserved.
//


// klasa na potrzeby obslugi klawiatury, dlatego tez jest klasa xib
import UIKit
import MGSwipeTableCell

protocol RecordingCellDelgate {
    func recordingCell(cell: RecordingCell, finishEditingName newName: String)
}

class RecordingCell: MGSwipeTableCell {
    
// deklaracja pola z tekstem z pliku xib 
    @IBOutlet weak var recordingTitleLabel: UITextField!
    // deklaracja starej nazwy
    var oldName: String!
    // deklaracja zmiennej protokołu ?
    var cellDelegate: RecordingCellDelgate!

    // ki chuj ?
    override func awakeFromNib() {
    
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state ??
    }
    
    // funkcja chowania klawiatury
    @IBAction func hideKeyboard(sender: AnyObject?) {
        
        // first responder wysyla informacje o zmianie statusu ?, a dalej ?
        recordingTitleLabel.resignFirstResponder()
        cellDelegate.recordingCell(self, finishEditingName: recordingTitleLabel!.text!)
        recordingTitleLabel.enabled = false
    }
    
}
// 
extension RecordingCell: UITextFieldDelegate {

}
