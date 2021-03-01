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

class CallKitDelegate: NSObject {

    public let provider: CXProvider
    private let notifications = NotificationCenter.default
    private let pil: PIL

    init(pil: PIL) {
        self.pil = pil
        self.provider = CXProvider(configuration: CallKitDelegate.self.createConfiguration())
        super.init()
        self.provider.setDelegate(self, queue: nil)
    }

    func refresh() {
        self.provider.configuration = CallKitDelegate.self.createConfiguration()
    }

    private static func createConfiguration() -> CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(
                localizedName: Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        )

        providerConfiguration.maximumCallGroups = 2
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportsVideo = false
        providerConfiguration.supportedHandleTypes = [CXHandle.HandleType.phoneNumber]

//        if !SystemUser.current().usePhoneRingtone { //TODO: implement ringtone selection
//            if Bundle.main.path(forResource: "ringtone", ofType: "wav") != nil {
//                providerConfiguration.ringtoneSound = "ringtone.wav"
//            }
//        }

        return providerConfiguration
    }

    func reportIncomingCall() {
        guard let call = pil.call else {
            print("Reported incoming call with no active session")
            return
        }

        let update = CXCallUpdate()
        update.localizedCallerName = call.displayName

        _ = CXHandle(
                type: CXHandle.HandleType.phoneNumber,
                value: call.displayName ?? call.remoteNumber
        )
        print("Reporting call with uuid \(call.uuid)")
        provider.reportCall(with: call.uuid, updated: update)
    }

}

extension CallKitDelegate: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        print("Provider reset, end all the calls") //TODO: terminate the ongoing audio session and dispose of any active calls
    }

    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        PIL.shared?.acceptIncomingCall {
            action.fulfill()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = findCallOrFail(action: action) else {
            action.fulfill()
            return
        }
        
        print("Call is ending with average rating: \(call.mos)/5")
        let success = pil.actions.end(call:call)

        if success {
            action.fulfill(withDateEnded: Date())
        } else {
            action.fail()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
//        guard let call = findCall(action: action) else { return }

        action.fulfill()
    }

    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard findCallOrFail(action: action) != nil else { return }
        pil.actions.setMicrophone(muted: action.isMuted)

        action.fulfill()
    }

    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = findCallOrFail(action: action) else { return }

        let success = pil.actions.setHold(call: call, onHold: action.isOnHold)

        if success {
            action.fulfill()
        } else {
            action.fail()
        }
    }

    public func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
//        guard let call = findCallOrFail(action: action) else { return }

        print("DTMF not supported yet") //wip
        action.fail()
    }

    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        PhoneLib.shared.setAudio(enabled: true)
    }

    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        PhoneLib.shared.setAudio(enabled: false)
    }
}

extension CallKitDelegate {

    /**
        Attempts to find the call, if is not find, will automatically fail the action.
    */
    private func findCall(action: CXCallAction) -> PILCall? {
        print("Attempting to perform \(String(describing: type(of: action))).")

        guard let call = pil.findCallByUuid(uuid: action.callUUID) else {
            return nil
        }

        return call
    }

    /**
        Attempts to find the call. If it is not found, will automatically fail the action.
    */
    private func findCallOrFail(action: CXCallAction) -> PILCall? {
        guard let call = findCall(action: action) else {
            print("Failed to execute action \(String(describing: type(of: action))), call not found.")
            action.fail()
            return nil
        }

        return call
    }

    private func logError(error: Error?, call: PILCall) {
        print("Unable to perform action on call (\(call.uuid.uuidString)), error: \(error!.localizedDescription)")
    }

    private func waitForCallConfirmation(call: PILCall) -> Bool {
        if call.direction == CallDirection.outbound {
            return true
        }

        if isCallConfirmed() {
            return true
        }

        print("Awaiting the incoming call to be confirmed")

        _ = CallKitDelegate.wait(timeoutInMilliseconds: 5000) { isCallConfirmed() }

        print("Finished waiting with result: \(isCallConfirmed())")

        return isCallConfirmed()
    }

    private func isCallConfirmed() -> Bool {
        return VoIPPushHandler.incomingCallConfirmed
    }
}

extension CallKitDelegate {

    /**
        Wait for a given condition or until a certain timeout has been reached.
    */
    public static func wait(timeoutInMilliseconds: Int = 10000, until: () -> Bool) -> Bool {
        let TIMEOUT_MILLISECONDS = timeoutInMilliseconds
        let MILLISECONDS_BETWEEN_ITERATION = 5
        var millisecondsTrying = 0

        while (!until() && millisecondsTrying < TIMEOUT_MILLISECONDS) {
            millisecondsTrying += MILLISECONDS_BETWEEN_ITERATION
            usleep(useconds_t(MILLISECONDS_BETWEEN_ITERATION * 1000))
        }

        return until()
    }
}
