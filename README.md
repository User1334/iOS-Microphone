# iOS Microphone

Turn your old iPhone into a wired microphone. Routes audio from the built-in mic to the headphone jack in real-time.

## Why?

I wanted to use my old iPhone as a wired microphone for my Mac, because the phone had no other use. Useful for streaming, podcasting, or recording without buying a dedicated microphone — especially if you have an older iPhone with a 3.5mm jack lying around.

## Features

- One-tap mic passthrough (mic to speaker/headphones)
- Works in the background and with the screen locked
- Minimal latency using AVAudioEngine
- Supports iOS 9.0+

## Limitations

- Audio passthrough only — no recording or streaming features
- Tested on iPhone 6s through iPhone 15
- Not tested on iPad

## Important Notes

- **iPhone 7 and newer require a Lightning-to-3.5mm adapter** (or USB-C-to-3.5mm for iPhone 15+), since these models no longer have a built-in headphone jack.
- **Always use headphones or a connected output device.** Running the app without headphones will cause audio feedback (loud screeching) as the speaker output loops back into the microphone.

## Requirements

- iOS 9.0 or later
- A physical iOS device (microphone input is not available in the simulator)
- Xcode 12 for iOS 9 to 14 (legacy UIKit codebase)
- Xcode 26 for iOS 15.6 to 26.4.2 (SwiftUI codebase)

The project contains two separate implementations sharing the same core logic. Use the Xcode version matching your target iOS range.

## Setup

1. Clone the repository
2. Open `iOS Microphone.xcodeproj` in Xcode
3. Select your development team under **Signing & Capabilities**
4. Build and run on your device

## Usage

1. Connect headphones to your iPhone (use a Lightning or USB-C adapter for iPhone 7 and newer)
2. Launch the app and grant microphone permission
3. Tap the microphone button to start audio passthrough
4. Tap again to stop

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
