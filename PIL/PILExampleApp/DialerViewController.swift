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

    override func viewDidLoad() {
        super.viewDidLoad()

        numberPreview.text = ""
    }

    @IBAction func callButtonWasPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "callSegue", sender: self)
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
}
