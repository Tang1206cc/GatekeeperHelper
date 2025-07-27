//
//  SettingsView.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/27.
//

import Foundation
// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("偏好设置")
                .font(.title2)
                .bold()
            Divider()
            Text("这里是 GatekeeperHelper 的设置内容（待补充）")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 240)
    }
}
