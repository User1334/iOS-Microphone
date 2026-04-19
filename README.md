# iOS Microphone

Use your iPhone as a microphone. Captures audio from the built-in mic and routes it to the speaker or headphone jack in real-time.

## Features

- One-tap mic passthrough (mic to speaker/headphones)
- Works in the background and with the screen locked
- Minimal latency using AVAudioEngine
- Supports iOS 15+

## Requirements

- Xcode 15+
- iOS 13.0 or later
- A physical iOS device (microphone input is not available in the simulator)

## Setup

1. Clone the repository
2. Open `iOS Microphone.xcodeproj` in Xcode
3. Select your development team under **Signing & Capabilities**
4. Build and run on your device

## Usage

1. Launch the app and grant microphone permission
2. Tap the microphone button to start audio passthrough
3. Tap again to stop

## License

MIT
