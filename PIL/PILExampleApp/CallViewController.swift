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

    let pil = PIL.shared

    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
    
    @IBAction func hangUpButtonWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bluetoothButtonWasPressed(_ sender: Any) {
    }

    @IBAction func earpieceButtonWasPressed(_ sender: Any) {
    }

    @IBAction func speakerButtonWasPressed(_ sender: Any) {
    }

    @IBAction func transferButtonWasPressed(_ sender: Any) {
    }

    @IBAction func holdButtonWasPressed(_ sender: Any) {
    }

    @IBAction func muteButtonWasPressed(_ sender: Any) {
        
    }
}
