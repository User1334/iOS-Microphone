//
//  AppDelegate.swift
//  iOS-Microphone
//
//  App entry point using the traditional UIKit lifecycle.
//  Routes to SwiftUI (iOS 13+) or UIKit (iOS 9–12) depending on availability.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        #if (arch(arm64) || arch(x86_64)) && compiler(>=5.1) && canImport(SwiftUI)
        if #available(iOS 13.0, *) {
            window?.rootViewController = makeSwiftUIController()
        } else {
            window?.rootViewController = LegacyViewController()
        }
        #else
        window?.rootViewController = LegacyViewController()
        #endif
        
        window?.makeKeyAndVisible()
        return true
    }
    
    // MARK: - Scene Lifecycle (iOS 13+)
    
    #if (arch(arm64) || arch(x86_64)) && compiler(>=5.1) && canImport(SwiftUI)
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    #endif
}