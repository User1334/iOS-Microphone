//
//  AudioPassthroughManager.swift
//  iOS-Microphone
//
//  Core audio engine that captures microphone input and routes it
//  directly to the speaker or headphone output in real time.
//

import AVFoundation

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
    private var stoppedByMuteSwitch = false
    
    // MARK: - Init
    
    init() {
        UserDefaults.standard.register(defaults: ["echo_cancellation_enabled": false])
        checkMicPermission()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(defaultsChanged),
            name: UserDefaults.didChangeNotification,
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
        if isRunning {
            stoppedByMuteSwitch = true
            stop()
        } else if stoppedByMuteSwitch {
            stoppedByMuteSwitch = false
            start()
        }
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
            try session.setCategory(.playAndRecord)
            try session.overrideOutputAudioPort(.speaker)
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
            
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: inputFormat)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
                playerNode.scheduleBuffer(buffer)
            }
            
            try engine.start()
            playerNode.play()
            
            self.audioEngine = engine
            self.isRunning = true
        } catch {
            errorMessage = "Audio error: \(error.localizedDescription)"
            isRunning = false
        }
    }
    
    func stop() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
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