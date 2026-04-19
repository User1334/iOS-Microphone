//
//  ContentView.swift
//  iOS Microphone
//
//  Created by User1337 on 18.04.26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioPassthroughManager()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("iOS Microphone")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(audioManager.isRunning ? "Microphone Active" : "Microphone Disabled")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Big mic button
            Button {
                audioManager.toggle()
            } label: {
                Image(systemName: audioManager.isRunning ? "mic.fill" : "mic.slash.fill")
                    .font(.system(size: 64))
                    .foregroundColor(audioManager.isRunning ? .red : .primary)
                    .frame(width: 150, height: 150)
                    .background(
                        Circle()
                            .fill(audioManager.isRunning ? Color.red.opacity(0.15) : Color.secondary.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
            
            if !audioManager.micPermissionGranted {
                Text("Microphone access required")
                    .font(.callout)
                    .foregroundColor(.orange)
            }
            
            if let error = audioManager.errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Audio is routed from the microphone to the speaker/headphones.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

#Preview {
    ContentView()
}
