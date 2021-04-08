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
    
    private var callSessionState: CallSessionState?
    private var event: Event?
    
    override func viewWillAppear(_ animated: Bool) {
        render()
        pil.events.listen(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        pil.events.stopListening(delegate: self)
    }
    
    func onEvent(event: Event, callSessionState: CallSessionState) {
        print("Received \(event)")
        
        self.event = event
        self.callSessionState = callSessionState
        render()
    }
    
    private func render() {
        guard let call = callSessionState?.activeCall ?? pil.calls.active else {
            self.dismiss(animated: true)
            return
        }
        
        renderCallInfo(call: call)
        renderCallButtons(call: call)
        renderForEventStatus(call: call)
    }
    
    private func renderCallInfo(call: Call) {
        callTitle.text = "\(call.remotePartyHeading) - \(call.remotePartySubheading)"
        callSubtitle.text = String(describing: call.direction)
        callDuration.text = String(describing: call.duration)
        callStatus.text = String(describing: call.state)
    }
    
    private func renderCallButtons(call: Call) {
        let audioState: AudioState
        let isMicrophoneMuted: Bool
        if let callSessionState = self.callSessionState {
            audioState = callSessionState.audioState
            isMicrophoneMuted = audioState.isMicrophoneMuted
        } else {
            audioState = pil.audio.state
            isMicrophoneMuted = pil.audio.isMicrophoneMuted
        }
        
        if isMicrophoneMuted {
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
        
        bluetoothButton.isEnabled = audioState.availableRoutes.contains(.bluetooth)
        earpieceButton.isEnabled = audioState.availableRoutes.contains(.phone)
        speakerButton.isEnabled = audioState.availableRoutes.contains(.speaker)
        
        speakerButton.isSelected = audioState.currentRoute == .speaker
        bluetoothButton.isSelected = audioState.currentRoute == .bluetooth
        earpieceButton.isSelected = audioState.currentRoute == .phone
        
        bluetoothButton.setTitle(audioState.bluetoothDeviceName ?? "BLUETOOTH", for: .normal)
        
        if callSessionState?.inactiveCall != nil {
            transferButton.setTitle("MERGE", for: .normal)
        } else {
            transferButton.setTitle("TRANSFER", for: .normal)
        }
    }
    
    private func renderForEventStatus(call: Call) {
        switch event {
        case .incomingCallReceived:
            showEventStatus(message: "Incoming Call Received: In call with \(call.displayName)")
        case .outgoingCallStarted:
            showEventStatus(message: "Outgoing Call Started: In call with  \(call.displayName)")
        case .callConnected:
            showEventStatus(message: "Call Connected: In call with \(call.displayName)")
        case .callEnded:
            if callSessionState?.activeCall == nil && callSessionState?.inactiveCall == nil {
                self.dismiss(animated: true, completion: nil)
            }
        case .attendedTransferStarted:
            showEventStatus(message: "Call Transfer Started: Calling \(call.displayName)")
        case .attendedTransferAborted:
            showEventStatus(message: "Call Transfer Aborted: In call with \(call.displayName)")
        case .attendedTransferConnected:
            showEventStatus(message: "Call Transfer Connected: In call with  \(call.displayName)")
        case .attendedTransferEnded:
            if let inactiveCall = callSessionState?.inactiveCall {
                showEventStatus(message: "Call Transfer Ended: Merged calls with \(call.displayName) and \(inactiveCall.displayName)")
            }
        case .incomingCallSetupFailed:
            showEventStatus(message: "Incoming Call Setup Failed.")
        case .outgoingCallSetupFailed:
            showEventStatus(message: "Outgoing Call Setup Failed.")
        case .none, .callDurationUpdated:
            return
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
        if callSessionState?.inactiveCall == nil {
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
    
    private func showEventStatus(message: String) {
        inactiveCallStatus.text = message
        let screenWidth = UIScreen.main.bounds.width
        inactiveCallStatus.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
    }
}