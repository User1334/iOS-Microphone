//
//  AudioPassthroughManager.swift
//  iOS-Microphone
//
//  Core audio engine that captures microphone input and routes it
//  directly to the speaker or headphone output in real time.
//

import AVFoundation
import Accelerate

final class AudioPassthroughManager {
    
    // MARK: - Observable State
    
    var isRunning = false { didSet { onStateChanged?() } }
    var micPermissionGranted = false { didSet { onStateChanged?() } }
    var errorMessage: String? { didSet { onStateChanged?() } }
    var echoCancellationEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "echo_cancellation_enabled")
    }
    var onStateChanged: (() -> Void)?
    
    // MARK: - Private
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var mutedBySwitch = false

    // MARK: - Init

    init() {
        UserDefaults.standard.register(defaults: ["echo_cancellation_enabled": false, "microphone_gain": 1.0])
        checkMicPermission()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(defaultsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteChanged),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )

        observeMuteSwitch()
    }

    deinit {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterRemoveEveryObserver(center, Unmanaged.passUnretained(self).toOpaque())
    }
    
    @objc private func defaultsChanged() {
        if isRunning {
            stop()
            start()
        }
    }

    @objc private func audioRouteChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt else { return }
        let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) ?? .unknown
        guard reason == .newDeviceAvailable || reason == .oldDeviceUnavailable else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self, self.isRunning || self.mutedBySwitch else { return }
            let wasMuted = self.mutedBySwitch
            self.stop()
            if !wasMuted {
                self.start()
            }
        }
    }
    
    // MARK: - Mute Switch
    
    private func observeMuteSwitch() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        
        CFNotificationCenterAddObserver(
            center,
            observer,
            { _, observer, _, _, _ in
                guard let observer = observer else { return }
                let manager = Unmanaged<AudioPassthroughManager>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.handleMuteSwitchChange()
                }
            },
            "com.apple.springboard.ringerstate" as CFString,
            nil,
            .deliverImmediately
        )
    }
    
    private func handleMuteSwitchChange() {
        guard audioEngine != nil else { return }
        mutedBySwitch = !mutedBySwitch
        isRunning = !mutedBySwitch
    }
    
    // MARK: - Permissions
    
    func checkMicPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            micPermissionGranted = true
        case .denied:
            micPermissionGranted = false
        case .undetermined:
            micPermissionGranted = false
        #if compiler(>=5)
        @unknown default:
            micPermissionGranted = false
        #else
        default:
            micPermissionGranted = false
        #endif
        }
    }
    
    func requestMicPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.micPermissionGranted = granted
                if !granted {
                    self?.errorMessage = "Microphone access denied. Please enable it in Settings."
                }
            }
        }
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        let mode: AVAudioSession.Mode = echoCancellationEnabled ? .voiceChat : .default
        
        #if compiler(>=5)
        if #available(iOS 10.0, *) {
            try session.setCategory(.playAndRecord, mode: mode, options: [.defaultToSpeaker, .allowBluetoothA2DP, .mixWithOthers])
        } else {
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        }
        #else
        try AudioSessionHelper.setPlayAndRecordCategory(withEchoCancellation: echoCancellationEnabled)
        #endif
        
        try session.setActive(true, options: [])
    }
    
    // MARK: - Audio Engine
    
    func start() {
        guard micPermissionGranted else {
            requestMicPermission()
            return
        }
        
        errorMessage = nil
        
        do {
            let session = AVAudioSession.sharedInstance()
            
            guard session.isInputAvailable else {
                errorMessage = "No audio input available."
                return
            }
            
            try configureAudioSession()
            
            let engine = AVAudioEngine()
            let inputNode = engine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            
            guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
                errorMessage = "No valid audio input format found."
                return
            }
            
            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: inputFormat)

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
                guard self?.mutedBySwitch != true else { return }
                var gain = UserDefaults.standard.float(forKey: "microphone_gain")
                if gain < 0.1 { gain = 1.0 }
                if gain != 1.0 {
                    let frameCount = Int(buffer.frameLength)
                    for ch in 0..<Int(buffer.format.channelCount) {
                        guard let samples = buffer.floatChannelData?[ch] else { continue }
                        vDSP_vsmul(samples, 1, &gain, samples, 1, vDSP_Length(frameCount))
                    }
                }
                player.scheduleBuffer(buffer)
            }

            try engine.start()
            player.play()

            self.playerNode = player
            self.audioEngine = engine
            self.isRunning = true
        } catch {
            errorMessage = "Audio error: \(error.localizedDescription)"
            isRunning = false
        }
    }
    
    func stop() {
        mutedBySwitch = false
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
        isRunning = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
}