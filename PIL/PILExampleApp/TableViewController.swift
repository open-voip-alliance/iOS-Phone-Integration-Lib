//
//  TableViewController.swift
//  PILExampleApp
//
//  Created by Chris Kontos on 08/01/2021.
//

import UIKit
import PIL

class TableViewController: UITableViewController {

    @IBOutlet private var domainTF: UITextField!
    @IBOutlet private var portTF: UITextField!
    @IBOutlet private var accountTF: UITextField!
    @IBOutlet private var passwordTF: UITextField!
    @IBOutlet private var stateLabel: UILabel!
    @IBOutlet private var useTLS: UISwitch!
    
    @IBOutlet private var numberTF: UITextField!
    
    @IBOutlet var callAnswer: UIButton!
    @IBOutlet var callDecline: UIButton!
    @IBOutlet var callHold: UIButton!
    @IBOutlet var callTransfer: UIButton!
    
//    var activeSession:Session?
//    var holdSession:Session?
    let pil = PIL.shared
    
    private var durationTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callAnswer.isHidden = true
        callDecline.isHidden = true
        callHold.isHidden = true
        callTransfer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //wip to be removed before release
        accountTF.text = "497920083"
        passwordTF.text = "pxNnxaxb56AK8hr"
        numberTF.text = "0630821207"
    }
    
    
//    func updateUI(session:Session, message:String) {
//        stateLabel.text = "\(message): \(session.displayName ?? "NO NAME") (\(session.remoteNumber))"
//        callAnswer.isHidden = false
//        callDecline.isHidden = false
//    }

    @IBAction func connect(_ sender: Any) {
        if pil.registrationStatus == .registered {
            (sender as! UIButton).setTitle("Connect", for: .normal)
            pil.unregister()
        } else {
            //wip let success =
            pil.auth = Auth(username: accountTF.text!, password: passwordTF.text!, domain: domainTF.text!, port: Int(portTF.text!)!, secure: useTLS.isOn)
            
            debugPrint("Account \(accountTF.text!) tried to register on \(domainTF.text!):\(portTF.text!).")
            
            print("//wip \(pil.registrationStatus)")
            (sender as! UIButton).setTitle(pil.registrationStatus == .registered ? "Disconnect" : "Failed", for: .normal)
        }
        
//        if PhoneLib.shared.registrationStatus == .registered {
//            PhoneLib.shared.unregister {
//                (sender as! UIButton).setTitle("Connect", for: .normal)
//            }
//        } else {
//            let success = PhoneLib.shared.register(domain: domainTF.text!,
//                                                      port: Int(portTF.text!)!,
//                                                      username: accountTF.text!,
//                                                      password: passwordTF.text!,
//                                                      encrypted: useTLS.isOn)
//            debugPrint("Account \(accountTF.text!) tried to register on \(domainTF.text!):\(portTF.text!) with result: \(success).")
//            (sender as! UIButton).setTitle(success ? "Disconnect" : "Failed", for: .normal)
//            PhoneLib.shared.resetAudioCodecs()
//        }
    }
    
    @IBAction func call(_ sender: Any) {
//        //Two active lines.
//        if let active = activeSession {
//            _ = PhoneLib.shared.setHold(session: active, onHold: true)
//            holdSession = active
//            activeSession = nil
//        }
//        let outgoingCall = PhoneLib.shared.call(to: numberTF.text!)
//        let outgoingSuccess = outgoingCall != nil
//        stateLabel.text = "Call res: \(outgoingSuccess)"
//        debugPrint("Call res: \(outgoingSuccess)")
//        callDecline.isHidden = !outgoingSuccess
    }
    
    @IBAction func answer(_ sender: Any) {
//        guard let session = activeSession else { return }
//        stateLabel.text = "Answer: \(PhoneLib.shared.acceptCall(for: session))"
//        callAnswer.isHidden = true
//        callTransfer.isHidden = false
    }
    
    @IBAction func decline(_ sender: Any) {
//        guard let session = activeSession else { return }
//        stateLabel.text = "Ended: \(PhoneLib.shared.endCall(for: session))"
//        callAnswer.isHidden = true
//        callDecline.isHidden = true
//        callTransfer.isHidden = true
    }
    
    @IBAction func holdCall(_ sender: UIButton) {
//        guard let session = activeSession else { return }
//        stateLabel.text = "Hold successful: \(PhoneLib.shared.setHold(session: session, onHold: session.state != .paused))"
//        sender.setTitle(session.state == .pausing ? "Unhold" : "Hold", for: .normal)
    }
    
    @IBAction func transfer(_ sender: Any) {
//        //1. Create the alert controller.
//        let alert = UIAlertController(title: "Transfer to number", message: nil, preferredStyle: .alert)
//
//        //2. Add the text field. You can configure it however you need.
//        alert.addTextField { (textField) in
//            textField.placeholder = "Number"
//            textField.keyboardType = .numberPad
//        }
//
//        // 3. Grab the value from the text field, and print it when the user clicks OK.
//        alert.addAction(UIAlertAction(title: "Transfer", style: .default, handler: { [weak alert] (_) in
//            guard let textField = alert?.textFields?.first, !textField.text!.isEmpty else { return }
//            let _ = PhoneLib.shared.transfer(session: self.activeSession!, to: textField.text!)
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
//
//        // 4. Present the alert.
//        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleMic(_ sender: UIButton) {
//        PhoneLib.shared.setMicrophone(muted: !PhoneLib.shared.isMicrophoneMuted)
//        sender.setTitle(PhoneLib.shared.isMicrophoneMuted ? "Unmute mic" : "Mute mic", for: .normal)
    }
    
    @IBAction func toggleSpeaker(_ sender: UIButton) {
//        _ = PhoneLib.shared.setSpeaker(!PhoneLib.shared.isSpeakerOn)
//        sender.setTitle(PhoneLib.shared.isSpeakerOn ? "Turn off speaker" : "Turn on speaker", for: .normal)
    }
}

//extension TableViewController: RegistrationStateDelegate {
//    func didChangeRegisterState(_ state: SipRegistrationStatus, message: String?) {
//        switch state {
//        case .none:
//            stateLabel.text = "None: \(message ?? "")"
//        case .progress:
//            stateLabel.text = "Progress: \(message ?? "")"
//        case .registered:
//            stateLabel.text = "Registered: \(message ?? "")"
//        case .cleared:
//            stateLabel.text = "Cleared: \(message ?? "")"
//        case .failed:
//            stateLabel.text = "Failed: \(message ?? "")"
//        }
//    }
//}
//
//extension TableViewController: SessionDelegate {
//    func didReceive(incomingSession: Session) {
//        self.activeSession = incomingSession
//        updateUI(session: incomingSession, message: "Incoming call")
//    }
//
//    func outgoingDidInitialize(session: Session) {
//        self.activeSession = session
//        updateUI(session: session, message: "Outgoing init")
//        print("outgoingDidInitialize")
//    }
//
//    func sessionUpdated(_ session: Session, message: String) {
//        self.activeSession = session
//        updateUI(session: session, message: "Updated: \(message)")
//        print("Session updated: \(session.state)")
//    }
//
//    func sessionConnected(_ session: Session) {
//        self.activeSession = session
//        updateUI(session: session, message: "Connected")
//        if durationTimer == nil {
//            durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (t) in
//                self.stateLabel.text = "Call: \(session.displayName ?? "NO NAME") (\(session.remoteNumber)) (\(session.durationInSec ?? 0))"
//            })
//        }
//        callHold.isHidden = false
//        callTransfer.isHidden = false
//        print("sessionConnected")
//    }
//
//    func sessionEnded(_ session: Session) {
//        self.activeSession = session
//        updateUI(session: session, message: "Ended")
//
//        durationTimer?.invalidate()
//        callHold.isHidden = true
//        callAnswer.isHidden = true
//        callDecline.isHidden = true
//        print("sessionEnded")
//    }
//
//    public func sessionReleased(_ session: Session) {
//        self.activeSession = session
//        updateUI(session: session, message: "Released")
//        durationTimer?.invalidate()
//        print("sessionReleased")
//    }
//
//    func error(session:Session, message: String) {
//        updateUI(session: session, message: "Error: \(message)")
//        print("error")
//    }
//}
