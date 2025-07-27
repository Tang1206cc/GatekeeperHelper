//
//  FixAppModalView.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/26.
//

import Foundation
import SwiftUI
import AppKit

struct FixAppModalView: View {
    let appURL: URL
    let issue: UnlockIssue
    @Binding var selectedMethod: UnlockMethod
    @Environment(\.dismiss) var dismiss

    var appIcon: NSImage? {
        NSWorkspace.shared.icon(forFile: appURL.path)
    }

    var body: some View {
        VStack(spacing: 20) {
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.bottom, 4)
            }

            Text("已选择 App")
                .font(.headline)

            Text(appURL.path)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if issue.title == "“xxx已损坏，无法打开。您应该推出磁盘映像/移到废纸篓”" {
                Picker("选择解锁方式", selection: $selectedMethod) {
                    ForEach(UnlockMethod.allCases, id: \.self) { method in
                        Text(method.description).tag(method)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }

            Button("立即修复") {
                switch issue.title {
                case "“xxx”意外退出":
                    Unlocker.codesignApp(at: appURL)
                default:
                    Unlocker.unlock(appAt: appURL, with: selectedMethod)
                }
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("取消") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 360)
    }
}
