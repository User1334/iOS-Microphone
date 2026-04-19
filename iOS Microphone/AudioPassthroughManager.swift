//
//  AudioPassthroughManager.swift
//  iOS Microphone
//
//  Created by User1337 on 18.04.26.
//

import AVFoundation
import Combine

final class AudioPassthroughManager: ObservableObject {
    @Published var isRunning = false
    @Published var micPermissionGranted = false
    @Published var errorMessage: String?
    
    private var audioEngine: AVAudioEngine?
    
    init() {
        checkMicPermission()
    }
    
    func checkMicPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            micPermissionGranted = true
        case .denied:
            micPermissionGranted = false
        case .undetermined:
            micPermissionGranted = false
        @unknown default:
            micPermissionGranted = false
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
    
    func start() {
        guard micPermissionGranted else {
            requestMicPermission()
            return
        }
        
        errorMessage = nil
        
        do {
            // Configure audio session BEFORE creating the engine
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetoothA2DP, .mixWithOthers])
            try session.setActive(true, options: [])
            
            let engine = AVAudioEngine()
            let inputNode = engine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            
            // Guard against invalid format
            guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
                errorMessage = "No valid audio input format found."
                return
            }
            
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: inputFormat)
            
            // Capture mic audio via tap and schedule it for playback
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
