//
//  DialerViewController.swift
//  PILExampleApp
//
//  Created by Jeremy Norman on 12/02/2021.
//

import Foundation
import UIKit
import PIL
import Contacts

class DialerViewController: UIViewController {
    
    @IBOutlet weak var numberPreview: UITextField!
        
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        numberPreview.text = ""
        
        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
            
        }
    }

    @IBAction func callButtonWasPressed(_ sender: UIButton) {
        guard let number = numberPreview.text,
              let pil = PIL.shared else { return }
        
        pil.start { _ in
                MicPermissionHelper.requestMicrophonePermission { startCalling in
                    if startCalling {
                        pil.call(number: number)
                    }
                }
        }
    }
    
    @IBAction func deleteButtonWasPressed(_ sender: UIButton) {
        let currentNumberPreview = numberPreview.text ?? ""
        
        if currentNumberPreview.isEmpty { return }
        
        numberPreview.text = String(currentNumberPreview.prefix(currentNumberPreview.count - 1))
    }
    
    @IBAction func keypadButtonWasPressed(_ sender: UIButton) {
        let currentNumberPreview = numberPreview.text ?? ""
        let buttonNumber = sender.currentTitle ?? ""
        
        numberPreview.text = currentNumberPreview + buttonNumber
    
        guard let pil = PIL.shared else { return }
        if self.defaults.bool(forKey: "play_dtmf_tones") {
            pil.audio.dtmf.playTone(character: buttonNumber)
        }
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    } //TODO: move this outside ViewControllers
}
