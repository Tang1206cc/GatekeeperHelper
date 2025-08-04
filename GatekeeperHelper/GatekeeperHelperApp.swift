import SwiftUI

@main
struct GatekeeperHelperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1020, minHeight: 580) // ✅ 正确：作用于 ContentView，而不是 WindowGroup
        }
        .defaultSize(width: 1120, height: 660) // ✅ 默认打开窗口尺寸
        .windowStyle(DefaultWindowStyle())

        Settings {
            SettingsView()
        }
    }
}
