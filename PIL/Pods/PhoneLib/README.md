# The iOS Spindle PhoneLib

This is the Spindle PhoneLib 

This framework is designed to make it easier to implement SIP functions into an app.
Currently it uses Linphone as the underlying SIP SDK. But it's built in a way that the SIP SDK can easily be swapped by another one.

**This is a Proof-Of-Concept.**

## Installation

### CocoaPods

To install it, simply add the following line to your Podfile:

```
pod 'PhoneLib' ,:git => '<GIT_URL>'
```

Run `pod install`

The current PhoneLib version is based on Linphone. Which is not available through the public Cocoapods specification. So you will need to add the following sources at the top of your podfile:

```
source 'https://gitlab.linphone.org/BC/public/podspec.git'
source 'https://github.com/CocoaPods/Specs.git'
```


## Permissions

Currently the only necessary permission is: `NSMicrophoneUsageDescription`. Add it to your `Info.plist`.

## Registration

Step 1: Import
```
import PhoneLib
```

Step 2: Implement the `RegistrationStateDelegate` and  `SessionDelegate`. Then assign your manager as the delegate for `PhoneLib`.

```
PhoneLib.shared.sessionDelegate = self
PhoneLib.shared.registrationDelegate = self
```

Step 3: Use `register` to register the softphone. 

```
register(domain:String, port:Int, username:String, password:String, encryption:Bool) -> Bool 
```

If this functions returns `true` the setup was successful. Once the softphone is registered the app will get an callback through `didChangeRegisterState(_ state: SipRegistrationStatus)`.
This function will keep your app posted on any state changes regarding the registration state.



## Call functions

The framework is based around the `Session` object. All call related functions are based around it. Your app must manage these Session objects.
In the current version of `Session` there's a `call: OpaquePointer` property. This is the only Linphone specific property. 

### Outgoing call
Once registered you can make a call by calling `call(to: String) -> Bool`.

```
let successful = PhoneLib.shared.call(to: String)
```

Store the session object.

### Incoming call
Incoming call are received via `didReceive(incomingSession: Session)` in the `SessionDelegate`.

In the next version this callback should be made broader so it can keep the app up-to-date about all Session state changes.

### Accept call
Accepting a call is done via `acceptCall(for session: Session) -> Bool`. 

### End call
Ending a call is done via `endCall(for session: Session) -> Bool`. 

## Codec functions

### Set Audio Codecs
Set Audio Codecs (Payloads) via `setAudioCodecs(_ codecs:[Codec])`.

### Reset Audio Codecs
Reset Audio codecs to initial state. Enables all codecs from the `Codec` enum via `setAudioCodecs(_ codecs:[Codec])`.

## Session functions

### Pause
Pausing a call can be doen by calling `pause()` on a Session object. 

### Resume
Resuming a call can be doen by calling `resume()` on a Session object. 

### Multiple acitve sessions
The app has to manage the references to the Session objects. Multiple active sessions can be done by pausing (See: `Pause`) a active Session and starting a new one. Or when there's a second incoming, pause the current. Use `Resume` to reactive a Session. 

### Set Microphone state
Set microphone via `setMicrophone(muted:Bool)`.

### Set Speaker state
Turn on/off the speaker.
This function uses AVAudioSession to override the `Output Audio Port`. It also sets the `category` to `PlayAndRecord` and `mode` to `VoiceChat`.
`setSpeaker(_ speaker:Bool) -> Bool`.

### Set a session on (un)hold
`setHold(session:Session, onHold hold:Bool) -> Bool`

### Set User Agent and version
`func setUserAgent(_ userAgent:String, version:String?)`


## CallKit 

### Enable/disable the audio session.
This is a `CallKit` support function. Which must be called by the `CXProviderDelegate` on `didActivate` and `didDeactivate`.
`setAudio(enabled:Bool)`

## Other
If you have any question please let us know via `info@coffeeit.nl`. Or by contacting the project manager.
