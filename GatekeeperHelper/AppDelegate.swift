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

    @objc func showPreferencesWindow(_ sender: Any?) {
        // 如果已存在设置窗口，则激活它
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // 否则创建一个新的设置窗口
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

        // 保存引用，以避免重复创建
        self.settingsWindow = window
    }
}
