//
//  GatekeeperHelperApp.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/24.
//

import SwiftUI

@main
struct GatekeeperHelperApp: App {
    // ✅ 连接 AppDelegate 实例
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        // ✅ 系统管理的原生偏好设置窗口
        Settings {
            SettingsView()
        }
    }
}
