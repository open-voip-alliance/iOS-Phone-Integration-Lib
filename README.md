## What is this?

This is a library that handles the challenges involved in integrating VoIP functionality into the iOS platform (hence Phone Integration Lib, or PIL for short).

### Does this library implement VoIP functionality?

No, it relies on [iOSVoIPLib](https://gitlab.wearespindle.com/vialer/mobile/voip/ios-voip-lib). A library that we also maintain which currently uses Linphone as the underlying SIP technology.

### Tasks handled by the PIL

- Starting and stopping the VoIP layer based on application state
- Managing registrations
- Managing call objects
- Integration with Call Kit
- Audio Routing
- Bluetooth calling
- Responding to bluetooth headset input
- Fetching contact data
- Displaying ViewControllers appropriately

### Tasks the application must implement

- Implement a closure to launch the Call ViewController
- [Optional] Implement a middleware class if required by your VoIP architecture
- [Optional] Implement a class to handle logs

## Example Application

This repo contains an example application with implementations of the basic functionality of the library, please check that if there are any questions not answered by this document.

## Getting Started

In your AppDelegate under the didFinishLaunchingWithOptions method, you must perform a number of actions.

1. Create the ApplicationSetup object:


```swift
let applicationSetup = ApplicationSetup(
    middleware: self,
    requestCallUi: {        
        if let nav = self.window?.rootViewController as? UITabBarController {
            nav.performSegue(withIdentifier: "LaunchCallSegue", sender: nav)
        }
    },
    logDelegate: self
)
```

The AppplicationSetup object is a way to bind certain parts of your code to functions in the PhoneIntegrationLib. These should all be considered static and should not change during the lifetime of your application. 

Mandatory parameters:

- requestCallUi = A closure that will be automatically triggered when the call ui should be launched, in this closure you are responsible for executing the code required to launch your call ui.

Optional parameters:

- logger = Receive logs from the PIL and the underlying VoIP library
- middleware = If your VoIP architecture uses a middleware, in that you use APNS notifications to wake the phone, you must provide an implementation of Middleware. While this isn't required, incoming calls will not work in the background without it.

2. Run startIOSPIL

```swift
_ = startIOSPIL(
    applicationSetup: applicationSetup,
    auth: Auth(
        username: "user123",
        password: "password123",
        domain: "sip.domain.com",
        port: 5061,
        secure: true
    ),
    autoStart: true
)
```

In this example we are hard-coding authentication details, in reality they will probably be fetched from some sort of storage. Passing TRUE to the autoStart parameter will simply automatically start the PIL rather than require an additional call to pil.start().  

It is possible to get an instance of the PIL at any point:

```swift
let pil = PIL.instance
```

### Configuring your application for VoIP

In xCode you must enable the following capabilities:

- Background Modes - Voice over VoIP
- Background Modes - Remote notifications
- Push notifications

And you must specify descriptions for:

- Privacy - Microphone Usage Description
- [Optional] Privacy - Contacts Usage Description

### Placing a call

```swift
pil.call("0123456789")
```

If configured correctly, everything else should be handled for you, including launching your ViewController.

## Displaying a call

To retrieve a call object, simply request it from the PIL instance:

```swift
let call: Call? = pil.call
```

This call object is immutable and is a snap-shot of the call at the time it was requested.

### Event Handling

The PIL will communicate with your app via events, the following is an example as to how you would use this to render your call ui.

1. Your ViewController should implement the PILEventDelegate protocol and begin listening for events in the appropriate lifecycle methods.

```swift
class CallViewController: UIViewController, PILEventDelegate

override func viewWillAppear(_ animated: Bool) {
    pil.events.listen(delegate: self)
}

override func viewDidDisappear(_ animated: Bool) {
    pil.events.stopListening(delegate: self)
}
```

2. You must then implement an onEvent method to handle these events.

```swift
func onEvent(event: Event, call: CallSessionState) {
        
}
```

As you can see, there is an optional CallSessionState parameter given. There are some events that will be triggered without an active call, in which case this will be nil.

The two relevant events for updating the call ui are .callUpdated and .callEnded.

.callUpdate is triggered very frequently and is informing you that something about the call has changed, as this includes the duration, you should expect this to be triggered at least once per second. When you receive this event you should update your ui to display the information from the most recent Call object.

.callEnded means you should dismiss your UI.

### Audio State

The audio state can be requested by querying:

```swift
let audioState: AudioState = pil.audio.state
```

Like the call object, this is also an immutable snap-shot at the time it was requested.

To check where you are currently routing audio simply call:

```swift
switch pi.audio.state.currentRoute {
    case .speaker:
    case .phone:
    case .bluetooth
}
```

or if you need to know if Bluetooth is available:

```swift
	pil.audio.state.availableRoutes.contains(.bluetooth)
```

## Interacting with a call

All call interactions can be found on the CallActions object which is accessed via the actions property on the PIL.

```swift
pil.actions.end()
```

```swift
pil.actions.toggleHold()
```

###  Audio

Audio is not necessarily directly tied to a call so it can be found under the audio property on the PIL.

```swift
pil.audio.mute()
```

```swift
pil.audio.routeAudio(.bluetooth)
```

## Customizing

There are two files that you should replace as they are used by CallKit:

- Image: PhoneIntegrationLibCallKitIcon - This is an icon that will appear on the CallKit UI and should always be replaced.
- Audio: phone_integration_lib_call_kit_ringtone.wav - This is the alternative ring tone that can be used if chosen.
