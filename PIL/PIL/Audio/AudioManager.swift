//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import iOSPhoneLib
import AVFoundation

public class AudioManager {
    
    private let phoneLib: PhoneLib
    private let audioSession: AVAudioSession
    private let pil: PIL
    
    init(pil: PIL, phoneLib: PhoneLib, audioSession: AVAudioSession) {
        self.pil = pil
        self.phoneLib = phoneLib
        self.audioSession = audioSession
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    public var isMicrophoneMuted: Bool {
        get {
            phoneLib.isMicrophoneMuted
        }
    }
    
    public var state: AudioState {
        get {
            guard let availableInputs = audioSession.availableInputs else {
                return AudioState(currentRoute: .phone, availableRoutes: [.phone, .speaker], bluetoothDeviceName: nil)
            }
            
            var routes: [AudioRoute] = [.speaker]
            
            if hasBluetooth() {
                routes.append(.bluetooth)
            }
            
            if hasPhone() {
                routes.append(.phone)
            }
            
            var currentRoute: AudioRoute = .phone
            
            if (!audioSession.currentRoute.outputs.filter({$0.portType == .builtInSpeaker}).isEmpty) {
                currentRoute = .speaker
            }
            
            if (!audioSession.currentRoute.outputs.filter({$0.portType == .bluetoothHFP || $0.portType == .headsetMic}).isEmpty) {
                currentRoute = .bluetooth
            }
            
            return AudioState(currentRoute: currentRoute, availableRoutes: routes, bluetoothDeviceName: findBluetoothName())
        }
    }
    
    public func routeAudio(route: AudioRoute) {
        guard let availableInputs = audioSession.availableInputs else {
            return
        }
        
        do {
            if route == .phone {
                try audioSession.overrideOutputAudioPort(.none)
            }
            
            if route == .speaker {
                try audioSession.overrideOutputAudioPort(.speaker)
            }
            
            if route == .bluetooth {
                try audioSession.overrideOutputAudioPort(.none)
                var input = availableInputs.filter({$0.portType == .bluetoothHFP}).first
                
                if input == nil {
                    input = availableInputs.filter({$0.portType == .headsetMic}).first
                }
                
                try audioSession.setPreferredInput(input)
            }
            
            try audioSession.setActive(true)
        } catch {
            print("Audio routing failed: \(error.localizedDescription)")
        }
        
        pil.events.broadcast(event: .callUpdated)
    }
    
    func onActivateAudioSession() {
        do {
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .duckOthers])
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Unable to activateasdasd audio \(error.localizedDescription)")
        }
        
        routeToDefault()
    }
    
    func onDeactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("Unable to deactivate audio \(error.localizedDescription)")
        }
    }
    
    private func routeToDefault() {
        if hasBluetooth() {
            routeAudio(route: .bluetooth)
        } else {
            routeAudio(route: .phone)
        }
    }
    
    private func hasBluetooth() -> Bool {
        return isAvailable(port: .bluetoothHFP) || isAvailable(port: .headsetMic)
    }
    
    private func hasSpeaker() -> Bool {
        return isAvailable(port: .builtInSpeaker)
    }
    
    private func hasPhone() -> Bool {
        return isAvailable(port: .builtInMic)
    }
    
    private func findBluetoothName() -> String? {
        guard let availableInputs = audioSession.availableInputs else {
            return nil
        }
        
        var name: String? = availableInputs.filter({ $0.portType == .bluetoothHFP }).first?.portName
        
        if name == nil {
            name = availableInputs.filter({ $0.portType == .headsetMic }).first?.portName
        }
        
        return name
    }
    
    private func isAvailable(port: AVAudioSession.Port) -> Bool {
        guard let availableInputs = audioSession.availableInputs else {
            return false
        }
        
        return !availableInputs.filter({$0.portType == port}).isEmpty
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        
        if reason == .oldDeviceUnavailable || reason == .newDeviceAvailable {
            routeToDefault()
        }
    }
}