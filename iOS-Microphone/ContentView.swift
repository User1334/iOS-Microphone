//
//  ContentView.swift
//  iOS-Microphone
//
//  SwiftUI interface for iOS 13+.
//  Excluded on Xcode 10 (compiler < 5.1) where SwiftUI does not exist.
//

#if compiler(>=5.1)
import SwiftUI
import Combine

// MARK: - Factory

@available(iOS 13.0, *)
func makeSwiftUIController() -> UIViewController {
    return UIHostingController(rootView: ContentView())
}

// MARK: - ViewModel

@available(iOS 13.0, *)
private class AudioViewModel: ObservableObject {
    let manager = AudioPassthroughManager()
    
    @Published var isRunning = false
    @Published var micPermissionGranted = false
    @Published var errorMessage: String?
    
    init() {
        manager.onStateChanged = { [weak self] in
            guard let self = self else { return }
            self.isRunning = self.manager.isRunning
            self.micPermissionGranted = self.manager.micPermissionGranted
            self.errorMessage = self.manager.errorMessage
        }
        isRunning = manager.isRunning
        micPermissionGranted = manager.micPermissionGranted
        errorMessage = manager.errorMessage
    }
    
    func toggle() { manager.toggle() }
}

// MARK: - View

@available(iOS 13.0, *)
struct ContentView: View {
    @ObservedObject private var viewModel = AudioViewModel()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("iOS Microphone")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(viewModel.isRunning ? "Microphone Active" : "Microphone Disabled")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.toggle()
            }) {
                Image(systemName: viewModel.isRunning ? "mic.fill" : "mic.slash.fill")
                    .font(.system(size: 64))
                    .foregroundColor(viewModel.isRunning ? .red : .primary)
                    .frame(width: 150, height: 150)
                    .background(
                        Circle()
                            .fill(viewModel.isRunning ? Color.red.opacity(0.15) : Color.secondary.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            if !viewModel.micPermissionGranted {
                Text("Microphone access required")
                    .font(.callout)
                    .foregroundColor(.orange)
            }
            
            if viewModel.errorMessage != nil {
                Text(viewModel.errorMessage!)
                    .font(.callout)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Text("For best results, use headphones.\nEcho cancellation can be enabled in Settings.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

#if compiler(>=5.9)
@available(iOS 13.0, *)
#Preview {
    ContentView()
}
#endif

#endif