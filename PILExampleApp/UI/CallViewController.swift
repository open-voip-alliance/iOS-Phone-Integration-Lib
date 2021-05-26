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
    @IBOutlet weak var inactiveCallStatus: UILabel!
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var holdButton: UIButton!
    @IBOutlet weak var earpieceButton: UIButton!
    @IBOutlet weak var bluetoothButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    
    let pil = PIL.shared!
    
    override func viewWillAppear(_ animated: Bool) {
        render()
        pil.events.listen(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        pil.events.stopListening(delegate: self)
    }
    
    func onEvent(event: Event, callSessionState: CallSessionState?) {
        print("Received call event \(event.hashValue)") //wip
        
        if let call = callSessionState?.activeCall {
            render(call: call)
        }

        if event == .callEnded && !pil.calls.isInCall {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func render(call: PILCall? = nil) {
    
        guard let call = (call ?? pil.calls.active) else {
            self.dismiss(animated: true)
            return
        }
        
        callTitle.text = "\(call.remotePartyHeading) - \(call.remotePartySubheading)"
        callSubtitle.text = String(describing: call.direction)
        callDuration.text = String(describing: call.duration)
        callStatus.text = String(describing: call.state)
        
        if pil.audio.isMicrophoneMuted {
            muteButton.isSelected = true
            muteButton.setTitle("UNMUTE", for: .normal)
        } else {
            muteButton.isSelected = false
            muteButton.setTitle("MUTE", for: .normal)
        }
        
        if call.isOnHold {
            holdButton.isSelected = true
            holdButton.setTitle("UNHOLD", for: .normal)
        } else {
            holdButton.isSelected = false
            holdButton.setTitle("HOLD", for: .normal)
        }
        
        let state = pil.audio.state
        
        bluetoothButton.isEnabled = state.availableRoutes.contains(.bluetooth)
        earpieceButton.isEnabled = state.availableRoutes.contains(.phone)
        speakerButton.isEnabled = state.availableRoutes.contains(.speaker)
        
        speakerButton.isSelected = state.currentRoute == .speaker
        bluetoothButton.isSelected = state.currentRoute == .bluetooth
        earpieceButton.isSelected = state.currentRoute == .phone
        
        bluetoothButton.setTitle(state.bluetoothDeviceName ?? "BLUETOOTH", for: .normal)
        
        if pil.calls.isInTranfer {
            inactiveCallStatus.isHidden = false
            if let inactiveCall = pil.calls.inactive {
                inactiveCallStatus.text = "\(inactiveCall.remotePartyHeading) - \(inactiveCall.remotePartySubheading)"
            }
            transferButton.setTitle("MERGE", for: .normal)
        } else {
            inactiveCallStatus.isHidden = true
            inactiveCallStatus.text = ""
            transferButton.setTitle("TRANSFER", for: .normal)
        }
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
    
    @IBAction func hangUpButtonWasPressed(_ sender: Any) {
        pil.actions.end()
    }
    
    @IBAction func bluetoothButtonWasPressed(_ sender: Any) {
        pil.audio.routeAudio(route: .bluetooth)
    }

    @IBAction func earpieceButtonWasPressed(_ sender: Any) {
        pil.audio.routeAudio(route: .phone)
    }

    @IBAction func speakerButtonWasPressed(_ sender: Any) {
        pil.audio.routeAudio(route: .speaker)
    }

    @IBAction func transferButtonWasPressed(_ sender: Any) {
        if (!pil.calls.isInTranfer) {
            promptForTransferNumber { number in
                self.pil.actions.beginAttendedTransfer(number: number)
            }
        } else {
            pil.actions.completeAttendedTransfer()
        }
    }

    @IBAction func holdButtonWasPressed(_ sender: Any) {
        pil.actions.toggleHold()
        render()
    }

    @IBAction func muteButtonWasPressed(_ sender: Any) {
        pil.actions.toggleMute()
        render()
    }
    
    @IBAction func dialpadButtonWasPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowInCallDialpadViewController", sender: self)
    }
    
    private func promptForTransferNumber(callback: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Call Transfer", message: "Enter the number to transfer to", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "080012341234"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Transfer", style: .default) { _ in
            callback(alertController.textFields![0].text!)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }
    
}
