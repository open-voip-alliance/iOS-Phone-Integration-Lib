//
//  CallViewController.swift
//  PILExampleApp
//
//  Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import PIL
import UIKit

class CallViewController: UIViewController, PILEventDelegate {
    
    @IBOutlet weak var callTitle: UILabel!
    @IBOutlet weak var callSubtitle: UILabel!
    @IBOutlet weak var callDuration: UILabel!
    @IBOutlet weak var callStatus: UILabel!

    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var holdButton: UIButton!
    @IBOutlet weak var earpieceButton: UIButton!
    @IBOutlet weak var bluetoothButton: UIButton!
    
    let pil = PIL.shared!
    
    override func viewWillAppear(_ animated: Bool) {
        pil.events.listen(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        pil.events.stopListening(delegate: self)
    }
    
    func onEvent(event: Event, call: PILCall?) {
        print("Received call event \(event.hashValue)")
        if let call = call {
            render(call: call)
        }
       
        if event == .callEnded {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func render(call: PILCall? = nil) {
    
        let call = call ?? pil.calls.active!
        
        callTitle.text = call.remoteNumber
        callSubtitle.text = String(describing: call.direction)
        callDuration.text = String(describing: call.duration)
        callStatus.text = String(describing: call.state)
        
        if pil.audio.isMicrophoneMuted {
            muteButton.setTitle("Unmute", for: .normal)
        } else {
            muteButton.setTitle("Mute", for: .normal)
        }
        
        if call.isOnHold {
            holdButton.setTitle("Hold", for: .normal)
        } else {
            holdButton.setTitle("Unhold", for: .normal)
        }
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
    
    @IBAction func hangUpButtonWasPressed(_ sender: Any) {
        pil.actions.end()
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
        //pil?.actions
        speakerButton.isSelected = !speakerButton.isSelected
    }

    @IBAction func transferButtonWasPressed(_ sender: Any) {
//        guard let call = pil?.call else { return }
//        if !call.isOnHold {
//            actions?.performHold()
//            holdButton.isSelected = !holdButton.isSelected
//        }
        //wip present UI to select number and call actions?.beginAttendedTransfer(number:)
    }

    @IBAction func holdButtonWasPressed(_ sender: Any) {
        pil.actions.toggleHold()
        render()
    }

    @IBAction func muteButtonWasPressed(_ sender: Any) {
        pil.actions.toggleMute()
        render()
    }
    
    
}
