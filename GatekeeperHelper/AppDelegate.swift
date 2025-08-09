//
//  AppDelegate.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/27.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var settingsWindow: NSWindow?
    private var escMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        escMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 && UserDefaults.standard.bool(forKey: "escToQuit") {
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
        AppSettings.applyLaunchAtLogin(UserDefaults.standard.bool(forKey: "launchAtLogin"))
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = escMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return UserDefaults.standard.bool(forKey: "quitWhenLastWindowClosed")
    }

    @objc func showPreferencesWindow(_ sender: Any?) {
        if let window = settingsWindow {
            window.setContentSize(NSSize(width: 480, height: 320))
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSMakeRect(0, 0, 480, 320),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "偏好设置"
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SettingsView())
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.settingsWindow = window
    }
}

