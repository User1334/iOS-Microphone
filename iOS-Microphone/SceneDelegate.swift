//
//  SceneDelegate.swift
//  iOS-Microphone
//
//  Handles the UIScene lifecycle on iOS 13+.
//  Excluded on Xcode 10 (compiler < 5.1) where SwiftUI does not exist.
//

#if compiler(>=5.1)
import UIKit
import SwiftUI

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: ContentView())
        window?.makeKeyAndVisible()
    }
}
#endif