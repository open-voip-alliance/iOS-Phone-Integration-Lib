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
        
    init(pil: PIL, voipLib: VoIPLib, callManager: CallManager) {
        self.pil = pil
        self.voipLib = voipLib
        self.callManager = callManager
        self.provider = CXProvider(configuration: IOSCallKit.self.createConfiguration())
        super.init()
    }
    
    public func initialize() {
        refresh()
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

        if let icon = UIImage(named: "PhoneIntegrationLibCallKitIcon") {
            providerConfiguration.iconTemplateImageData = icon.pngData()
        }
        
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportsVideo = false
        providerConfiguration.supportedHandleTypes = [CXHandle.HandleType.phoneNumber]

        if let pil = PIL.shared {
            if pil.preferences.useApplicationRingtone {
                if Bundle.main.path(forResource: "phone_integration_lib_call_kit_ringtone", ofType: "wav") != nil {
                    providerConfiguration.ringtoneSound = "phone_integration_lib_call_kit_ringtone.wav"
                }
            }
        }
        
        return providerConfiguration
    }

    func reportIncomingCall(detail: IncomingPayloadCallDetail) {
        self.pil.writeLog("Reporting incoming call!")
        
        let update = CXCallUpdate()

        update.remoteHandle = CXHandle(
                type: CXHandle.HandleType.phoneNumber,
                value: detail.phoneNumber
        )
        
        update.localizedCallerName = detail.callerId
        
        provider.reportNewIncomingCall(with: UUID.init(), update: update) { error in
            if error != nil {
                self.pil.writeLog("ERROR: \(error?.localizedDescription)")
            }
        }
    
        performSanityCheck()
    }
    
    private func performSanityCheck() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.hasActiveCalls {
                self.pil.writeLog("Performing sanity check that we have an active library while there are calls ringing")
                
                if !self.pil.voipLib.isReady {
                    self.pil.writeLog("VoIP library is not booted, ending all calls")
                    self.endAllCalls(reason: .failed)
                    return
                }
                   
                if !self.pil.calls.isInCall {
                    self.pil.writeLog("VoIP library appears to have been booted however there does not appear to be an active call, ending all CallKit calls.")
                    self.endAllCalls(reason: .failed)
                }
            }
        }
    }
    
    func cancelIncomingCall(reason: CXCallEndedReason = CXCallEndedReason.failed, date: Date = Date()) {
        if !hasActiveCalls {
            pil.writeLog("cancelIncomingCall was requested but there are no active CallKit calls.")
            return
        }
        
        controller.callObserver.calls.filter({ $0.uuid != self.findCallUuid()! && !$0.isOutgoing }).forEach { call in
            pil.writeLog("Cancelling incoming call with uuid \(call.uuid), the user will have been alerted for the incoming call already")
            provider.reportCall(with: call.uuid, endedAt: nil, reason: reason)
        }
    }
    
    func endAllCalls(reason: CXCallEndedReason = CXCallEndedReason.remoteEnded, date: Date? = nil) {
        controller.callObserver.calls.forEach { call in
            pil.writeLog("Ending call with UUID: \(call.uuid), reason: \(reason.rawValue)")
            provider.reportCall(with: call.uuid, endedAt: date, reason: reason)
        }
    }
    
    func startCall(number: String) {
        if hasActiveCalls {
            pil.writeLog("Unable to start new call while CallKit has at least 1 active call")
            return
        }
        
        let handle = CXHandle(type: .phoneNumber, value: number)
        let action = CXStartCallAction(call: UUID.init(), handle: handle)
        action.isVideo = false
        
        controller.requestTransaction(with: action) { error in
            if let error = error {
                self.pil.writeLog("Failed to start call: \(error.localizedDescription)")
                self.pil.events.broadcast(event: .outgoingCallSetupFailed)
            }
        }
    }
    
    func reportOutgoingCallConnecting() {
        if let uuid = findCallUuid() {
            provider.reportOutgoingCall(with:uuid, startedConnectingAt: Date())
        }
    }
    
    func updateCall(update: CXCallUpdate) {
        if let uuid = findCallUuid() {
            pil.iOSCallKit.provider.reportCall(with: uuid, updated: update)
        }
    }
    
    public func findCallUuid() -> UUID? {
        if self.controller.callObserver.calls.count >= 1 {
            return self.controller.callObserver.calls[0].uuid
        } else {
            return nil
        }
    }
    
    private var hasActiveCalls: Bool {
        get {
            controller.callObserver.calls.count > 0
        }
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
            action.fulfill()
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
            
            self.pil.events.broadcast(event: .callDurationUpdated(state: self.pil.sessionState))
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
    }
}

extension IOSCallKit {

    private func callExists(_ action: CXCallAction? = nil, callback: (VoipLibCall) -> Void) {
        if let transferSession = callManager.transferSession {
            pil.writeLog("CXCallAction \(action.debugDescription) completed on transfer target")
            callback(transferSession.to)
            action?.fulfill()
            return
        }
        
        if let call = callManager.voipLibCall {
            pil.writeLog("CXCallAction \(action.debugDescription) completed on active call")
            callback(call)
            action?.fulfill()
            return
        }
        
        pil.writeLog("CXCallAction \(action.debugDescription) has failed")
        action?.fail()
    }
}

