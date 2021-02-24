//
//  CallViewController.swift
//  PILExampleApp
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import PIL
import UIKit

class CallViewController: UIViewController {
    
    @IBOutlet weak var callTitle: UILabel!
    @IBOutlet weak var callSubtitle: UILabel!
    @IBOutlet weak var callDuration: UILabel!
    @IBOutlet weak var callStatus: UILabel!

    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var holdButton: UIButton!
    @IBOutlet weak var earpieceButton: UIButton!
    @IBOutlet weak var bluetoothButton: UIButton!
    
    let pil = PIL.shared
    let actions = PIL.shared?.actions
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
    
    @IBAction func hangUpButtonWasPressed(_ sender: Any) {
        actions?.end()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bluetoothButtonWasPressed(_ sender: Any) {
        //wip
        bluetoothButton.isSelected = !bluetoothButton.isSelected
    }

    @IBAction func earpieceButtonWasPressed(_ sender: Any) {
        //wip
        earpieceButton.isSelected = !earpieceButton.isSelected
    }

    @IBAction func speakerButtonWasPressed(_ sender: Any) {
        actions?.toggleSpeaker()
        speakerButton.isSelected = !speakerButton.isSelected
    }

    @IBAction func transferButtonWasPressed(_ sender: Any) {
        guard let call = pil?.call else { return }
        if !call.isOnHold {
            actions?.performHold()
            holdButton.isSelected = !holdButton.isSelected
        }
        //wip present UI to select number and call actions?.beginAttendedTransfer(number:)
    }

    @IBAction func holdButtonWasPressed(_ sender: Any) {
        actions?.performToggleHold()
        holdButton.isSelected = !holdButton.isSelected
    }

    @IBAction func muteButtonWasPressed(_ sender: Any) {
        actions?.performMute()
        muteButton.isSelected = !muteButton.isSelected 
    }
}
