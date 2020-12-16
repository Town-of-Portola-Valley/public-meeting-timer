//
//  AppDelegate.swift
//  TestProject
//
//  Created by Craig Hughes on 12/14/20.
//

import SwiftUI

#if os(macOS)
import Cocoa
import Carbon.HIToolbox

class KeyResponderWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        print("Received: \(event.modifierFlags) \"\(event.keyCode)\"")
        let keyCode = Int(event.keyCode)
        switch keyCode {
            case kVK_Escape,
                 kVK_Delete: ((self.contentView as? NSHostingView<CountdownView>)?.rootView)?.state.reset()
            case kVK_Space,
                 kVK_Return: ((self.contentView as? NSHostingView<CountdownView>)?.rootView)?.state.startOrStop()
            default: return
        }
    }
}

let savedDurationKey = "Countdown duration"

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let savedDuration = UserDefaults.standard.integer(forKey: savedDurationKey)
        let countdownState = CountdownTimerState(countTo: savedDuration != 0 ? savedDuration : 180)
        let contentView = CountdownView(state: countdownState)
            .onReceive(countdownState.$countTo, perform: { newDuration in
                UserDefaults.standard.setValue(newDuration, forKey: savedDurationKey)
            })

        // Create the window and set the content view.
        window = KeyResponderWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.toggleFullScreen(nil)
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
}
#else
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let savedDuration = UserDefaults.standard.integer(forKey: savedDurationKey)
        let countdownState = CountdownTimerState(countTo: savedDuration != 0 ? savedDuration : 180)
        let contentView = CountdownView(state: countdownState)
            .onReceive(countdownState.$countTo, perform: { newDuration in
                UserDefaults.standard.setValue(newDuration, forKey: savedDurationKey)
            })

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
#endif
