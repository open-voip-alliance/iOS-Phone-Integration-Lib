//
//  IOS.swift
//  PIL
//
//  Created by Jeremy Norman on 06/03/2021.
//

import Foundation

public class IOS {
    
    private let pil: PIL
    
    init(pil: PIL) {
        self.pil = pil
    }
    
    public func applicationWillEnterForeground() {
        if pil.calls.active != nil {
            pil.app.requestCallUi()
        }
        
        pil.start()
    }
    
    public func applicationDidEnterBackground() {
        
    }
}
