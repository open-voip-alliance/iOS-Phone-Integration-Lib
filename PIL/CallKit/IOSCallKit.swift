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
import iOSVoIPLib

class IOSCallKit: NSObject {

    private var timer: Timer?
    public var provider: CXProvider
    public let controller = CXCallController()
    private let notifications = NotificationCenter.default
    private let pil: PIL
    private let voipLib: VoIPLib
    private let callManager: CallManager
    
    /**
        This is the UUID of the current, active, valid call. This should never be set to anything aside from a call we know is valid.
     */
    internal var uuid:UUID?
    
    init(pil: PIL, voipLib: VoIPLib, callManager: CallManager) {
        self.pil = pil
        self.voipLib = voipLib
        self.callManager = callManager
        self.provider = CXProvider(configuration: IOSCallKit.self.createConfiguration())
        super.init()
    }
    
    public func initialize() {
        self.provider = CXProvider(configuration: IOSCallKit.self.createConfiguration())
        self.provider.setDelegate(self, queue: nil)
        self.controller.callObserver.setDelegate(self, queue: .main)
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
        let uuid = UUID.init()
        
        if !hasActiveCalls() {
            self.uuid = uuid
        }
        
        let update = CXCallUpdate()

        update.remoteHandle = CXHandle(
                type: CXHandle.HandleType.phoneNumber,
                value: detail.phoneNumber
        )
        
        update.localizedCallerName = detail.callerId
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error != nil {
                self.pil.writeLog("ERROR: \(error?.localizedDescription)")
            }
        }
    }
    
    func cancelIncomingCall(reason: CXCallEndedReason = CXCallEndedReason.failed, date: Date = Date()) {
        if !hasActiveCalls() {
            pil.writeLog("cancelIncomingCall was requested but there are no active CallKit calls.")
            return
        }
        
        controller.callObserver.calls.filter({ $0.uuid != self.uuid }).forEach { call in
            if !call.isOutgoing && !call.hasConnected {
                pil.writeLog("Cancelling incoming call with uuid \(call.uuid), the user will have been alerted for the incoming call already")
                provider.reportCall(with: call.uuid, endedAt: date, reason: reason)
            }
        }
    }
    
    func end() {
        controller.callObserver.calls.forEach { call in
            provider.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
        }
    }
    
    func startCall(number: String) {
        if hasActiveCalls() {
            pil.writeLog("Unable to start new call while CallKit has at least 1 active call")
            return
        }
        
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

    private func hasActiveCalls() -> Bool {
        controller.callObserver.calls.count > 0
    }
}

extension IOSCallKit: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        voipLib.terminateAllCalls()
    }

    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        callExists(action) { call in
            voipLib.actions(call: call).accept()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        callExists(action) { call in
            voipLib.actions(call: call).end()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        if let number = action.handle.value as? String {
            self.voipLib.call(to: number)
            action.fulfill()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        voipLib.isMicrophoneMuted = action.isMuted
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        callExists(action) { call in
            voipLib.actions(call: call).hold(onHold: action.isOnHold)
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        callExists(action) { call in
            voipLib.actions(call: call).sendDtmf(dtmf: action.digits)
        }
    }

    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        callExists { call in
            voipLib.actions(call: call).setAudio(enabled: true)
        }
        
        pil.audio.onActivateAudioSession()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            if self.pil.calls.active == nil {
                timer.invalidate()
            }
            
            self.pil.events.broadcast(event: .callUpdated)
        })
    }

    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        callExists { call in
            voipLib.actions(call: call).setAudio(enabled: false)
        }
        
        pil.audio.onDeactivateAudioSession()
        timer?.invalidate()
    }
}

extension IOSCallKit: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        let callCount = callObserver.calls.count
        
        if callCount >= 2 {
            pil.writeLog("We have detected multiple calls, we must cancel them.")
            cancelIncomingCall()
        }
        
        pil.writeLog("CXCallObserverDelegate has detected call change, currently has \(callCount) calls")
                
        if callCount == 0 {
            self.uuid = nil
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
            pil.events.broadcast(event: .callUpdated)
            return
        }
        
        action?.fail()
    }
}

