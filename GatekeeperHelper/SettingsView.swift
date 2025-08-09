//
//  SettingsView.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/27.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("themeMode") private var themeMode = ThemeMode.system.rawValue
    @AppStorage("escToQuit") private var escToQuit = false
    @AppStorage("quitWhenLastWindowClosed") private var quitWhenLastWindowClosed = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("偏好设置")
                .font(.title2)
                .bold()
            Divider()

            Toggle("开机自启动", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { value in
                    AppSettings.applyLaunchAtLogin(value)
                }

            HStack {
                Text("主题模式")
                Picker("主题模式", selection: $themeMode) {
                    ForEach(ThemeMode.allCases) { mode in
                        Text(mode.displayName).tag(mode.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 220)
            }

            Toggle("按 Esc 键退出 GatekeeperHelper", isOn: $escToQuit)
            Toggle("关闭最后一个窗口时退出 GatekeeperHelper", isOn: $quitWhenLastWindowClosed)

            Spacer()

            Button("恢复默认设置") {
                AppSettings.reset()
                launchAtLogin = false
                themeMode = ThemeMode.system.rawValue
                escToQuit = false
                quitWhenLastWindowClosed = true
            }
            .padding(.bottom, 8)
        }
        .padding(24)
        .frame(width: 480, height: 320, alignment: .topLeading)
    }
}

