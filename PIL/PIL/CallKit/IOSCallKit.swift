//
//  CallKitDelegate.swift
//  PIL
//
//  Created by Chris Kontos on 22/12/2020.
//

import Foundation
import CallKit
import UserNotifications
import AVKit
import iOSPhoneLib

class IOSCallKit: NSObject {

    public let provider: CXProvider
    public let controller = CXCallController()
    private let notifications = NotificationCenter.default
    private let pil: PIL
    private let phoneLib: PhoneLib
    private let callManager: CallManager
    
    internal var uuid:UUID?
    
    init(pil: PIL, phoneLib: PhoneLib, callManager: CallManager) {
        self.pil = pil
        self.phoneLib = phoneLib
        self.callManager = callManager
        self.provider = CXProvider(configuration: IOSCallKit.self.createConfiguration())
        super.init()
        self.provider.setDelegate(self, queue: nil)
    }
    
    public func initialize() {
        
    }

    func refresh() {
        self.provider.configuration = IOSCallKit.self.createConfiguration()
    }

    private static func createConfiguration() -> CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(
                localizedName: Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        )

        if let icon = UIImage(named: "CallKitIcon") {
            providerConfiguration.iconTemplateImageData = icon.pngData()
        }
        
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportsVideo = false
        providerConfiguration.supportedHandleTypes = [CXHandle.HandleType.phoneNumber]

        if let pil = PIL.shared {
            if pil.preferences.useApplicationRingtone {
                if Bundle.main.path(forResource: "ringtone", ofType: "wav") != nil {
                    providerConfiguration.ringtoneSound = "ringtone.wav"
                }
            }
        }
        
        return providerConfiguration
    }

    func reportIncomingCall(detail: IncomingPayloadCallDetail) {
        self.uuid = UUID.init()
        let update = CXCallUpdate()

        update.remoteHandle = CXHandle(
                type: CXHandle.HandleType.phoneNumber,
                value: detail.phoneNumber
        )
        
        update.localizedCallerName = detail.callerId
        
        provider.reportNewIncomingCall(with: self.uuid!, update: update) { error in
            if error != nil {
                self.pil.writeLog("ERROR: \(error?.localizedDescription)")
            }
        }
    }
    
    func startCall(number: String) {
        self.uuid = UUID.init()
        let handle = CXHandle(type: .phoneNumber, value: number)
        let action = CXStartCallAction(call: self.uuid!, handle: handle)
        action.isVideo = false
        
        controller.requestTransaction(with: action) { error in
            if let error = error {
                self.pil.writeLog("Failed to start call: \(error.localizedDescription)")
                self.pil.events.broadcast(event: .outgoingCallSetupFailed)
            }
        }
    }

}

extension IOSCallKit: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        phoneLib.terminateAllCalls()
    }

    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        callExists(action) { call in
            phoneLib.actions(call: call).accept()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        callExists(action) { call in
            phoneLib.actions(call: call).end()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        if let number = action.handle.value as? String {
            self.phoneLib.call(to: number)
            action.fulfill()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        phoneLib.isMicrophoneMuted = action.isMuted
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        callExists(action) { call in
            phoneLib.actions(call: call).hold(onHold: action.isOnHold)
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        callExists(action) { call in
            phoneLib.actions(call: call).sendDtmf(dtmf: action.digits)
        }
    }

    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        callExists { call in
            phoneLib.actions(call: call).setAudio(enabled: true)
        }
    }

    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        callExists { call in
            phoneLib.actions(call: call).setAudio(enabled: false)
        }
    }
}

extension IOSCallKit {

    private func callExists(_ action: CXCallAction? = nil, callback: (Call) -> Void) {
        if let transferSession = callManager.transferSession {
            callback(transferSession.to)
            action?.fulfill()
            return
        }
        
        if let call = callManager.call {
            callback(call)
            action?.fulfill()
            pil.events.broadcast(event: .callUpdated, call: call)
            return
        }
        
        action?.fail()
    }
}

