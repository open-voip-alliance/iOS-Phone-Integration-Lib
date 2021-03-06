//
//  DialerViewController.swift
//  PILExampleApp
//
//  Created by Jeremy Norman on 12/02/2021.
//

import Foundation
import UIKit
import PIL

class DialerViewController: UIViewController {
    
    @IBOutlet weak var numberPreview: UITextField!
        
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        numberPreview.text = ""
    }

    @IBAction func callButtonWasPressed(_ sender: UIButton) {
        guard let number = numberPreview.text,
              let pil = PIL.shared else { return }
        pil.auth = Auth(
            username: self.userDefault(key: "username"),
            password: self.userDefault(key: "password"),
            domain: self.userDefault(key: "domain"),
            port: Int(self.userDefault(key: "port")) ?? 0,
            secure: self.defaults.bool(forKey: "encryption")
        )
        pil.start { 
                MicPermissionHelper.requestMicrophonePermission { startCalling in
                    if startCalling {
                        pil.call(number: number)
                        self.performSegue(withIdentifier: "callSegue", sender: self)
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
    
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    } //TODO: move this outside ViewControllers
}
