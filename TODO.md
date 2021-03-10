# TODO - iOS Platform Integration Layer

## PIL
- [x] Configuration
  - [x] Library supports SIP credentials
    - [x] Username/password/domain/port
    - [x] Encryption on/off
  - [x] Library supports user preferences
    - [x] Codec
    - [x] Use app ringtone
- [x] Middleware
  - [x] Middleware protocol exists to offload registration to consuming app
  - [x] Using implementation from consuming app can properly establish push kit integration
- [x] Events
  - [x] Events can be listened for
  - [x] Events can be broadcast
  - [x] Events include call object where relevant
- [x] Call Management
  - [x] Immutable call object can be generated
    - [x] Remote number
    - [x] Display name
    - [x] Call state
    - [x] Direction
    - [x] Hold State 
    - [x] UUID
    - [x] Mos Value
    - [x] Contact information
  - [x] Calls are stored/tracked in the PIL based on events from the phonelib
- [x] Calling
  - [x] Outgoing
    - [x] Can place an outgoing call to a given number
    - [x] Hooks up with call kit
    - [x] Automatically displays call screen if chosen
  - [x] Incoming
    - [x] App calls while in background
    - [x] User can answer call
    - [x] User can decline call
    - [x] Works with bluetooth devices
    - [x] User is taken to call screen after accepting call
  - [x] General
    - [x] Audio can be routed to bluetooth
    - [x] Audio can be routed to speaker
    - [x] Audio can be routed to earpiece
    - [x] Call can be muted
    - [x] Call can be put on hold
    - [x] Transfer
      - [x] User can begin transfer to new number
      - [x] User hears audio from second call after beginning transfer
      - [x] User can complete transfer
- [x] Call Kit
  - [x] Call kit integration is working
  - [x] Calls respond to presses on notifications
  - [x] Works with smart-watches
- [x] Lifecycle
  - [x] Is aware when the app is in the background
  - [x] Boot the library when the app is brought to foreground (if not already)
- [x] Code/Code Quality
  - [x] Only the absolutely necessary apis are exposed to the consuming applications
  - [x] A DI framework is used
  
## Example App
- [x] Setting Screen
  - [x] SIP Auth
    - [x] Username
    - [x] Password
    - [x] Domain
    - [x] Port
  - [x] VoIPGRID Auth
      - [x] Username
      - [x] Password
      - [x] Register with Middleware
  - [x] Preferences
      - [x] Encryption
      - [x] Use Application Ringtone 
- [x] Dialer Screen
  - [x] Input numbers
  - [x] View number input
  - [x] Place call
- [x] Call Screen
    - [x] Call Information Display
      - [x] Show third party
      - [x] Show call duration  
    - [x] Hold 💎👐
    - [x] Mute
    - [x] Transfer
    - [x] Route to Bluetooth
    - [x] Route to Speaker
    - [x] Route to Earpiece