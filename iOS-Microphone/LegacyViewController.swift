//
//  LegacyViewController.swift
//  iOS-Microphone
//
//  UIKit-based interface used on iOS 9–12 (or when built with Xcode 10).
//  Uses frame-based layout instead of Auto Layout anchors to stay
//  compatible with iOS 8+ (NSLayoutAnchor requires iOS 9).
//

import UIKit

class LegacyViewController: UIViewController {
    private let audioManager = AudioPassthroughManager()
    
    // MARK: - UI Elements
    
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        titleLabel.text = "iOS Microphone"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        
        statusLabel.font = UIFont.systemFont(ofSize: 17)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .gray
        
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(toggleButton)
        view.addSubview(errorLabel)
        
        audioManager.onStateChanged = { [weak self] in
            self?.updateUI()
        }
        updateUI()
    }
    
    // MARK: - Layout (frame-based for iOS 8 compatibility)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let centerX = view.bounds.midX
        let centerY = view.bounds.midY
        
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: centerX, y: centerY - 80)
        
        statusLabel.sizeToFit()
        statusLabel.center = CGPoint(x: centerX, y: centerY - 40)
        
        toggleButton.sizeToFit()
        toggleButton.center = CGPoint(x: centerX, y: centerY + 20)
        
        let errorWidth = view.bounds.width - 40
        errorLabel.frame = CGRect(x: 20, y: centerY + 60, width: errorWidth, height: 60)
    }
    
    // MARK: - Actions
    
    @objc private func toggleTapped() {
        audioManager.toggle()
    }
    
    // MARK: - State Updates
    
    private func updateUI() {
        statusLabel.text = audioManager.isRunning ? "Microphone Active" : "Microphone Disabled"
        statusLabel.sizeToFit()
        
        toggleButton.setTitle(audioManager.isRunning ? "Stop Microphone" : "Start Microphone", for: .normal)
        toggleButton.sizeToFit()
        
        errorLabel.text = audioManager.errorMessage
        errorLabel.isHidden = audioManager.errorMessage == nil
        
        view.setNeedsLayout()
    }
}