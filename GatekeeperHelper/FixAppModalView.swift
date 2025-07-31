//
//  FixAppModalView.swift
//  GatekeeperHelper
//

import Foundation
import SwiftUI
import AppKit

struct FixAppModalView: View {
    let appURL: URL
    let issue: UnlockIssue
    @Environment(\.dismiss) var dismiss

    // 第一类问题：已损坏
    @Binding var selectedMethod: UnlockMethod

    // 第二类问题：意外退出
    @State private var selectedAdvancedMethod: AdvancedUnlockMethod = .appBundle

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

            // 第一类问题
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

            // 第二类问题
            if issue.title == "“xxx”意外退出" {
                Picker("选择签名方式", selection: $selectedAdvancedMethod) {
                    ForEach(AdvancedUnlockMethod.allCases, id: \.self) { method in
                        Text(method.description).tag(method)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }

            Button("立即修复") {
                switch issue.title {
                case "“xxx已损坏，无法打开。您应该推出磁盘映像/移到废纸篓”":
                    if issue.title == "“xxx已损坏，无法打开。您应该推出磁盘映像/移到废纸篓”" && selectedMethod == .spctl {
                        // 永久禁用 Gatekeeper（危险）策略
                        let command = "/usr/sbin/spctl --master-disable"
                        let result: AuthResult = AuthorizationBridge.run(command: command)

                        switch result {
                        case .success:
                            // ✅ 执行成功：提示授权已完成，并引导前往设置
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(command, forType: .string)

                            let alert = NSAlert()
                            alert.messageText = "成功授权变更权限"
                            alert.informativeText = """
                    GatekeeperHelper 已为你授权开启“任何来源”选项。

                    请前往：设置 > 隐私与安全性 > 允许从以下来源的应用程序，并选择“任何来源”，以彻底关闭 Gatekeeper。

                    点击“好”将立即为你打开设置界面。
                    """
                            alert.addButton(withTitle: "好")
                            alert.runModal()

                            // 打开设置
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                                NSWorkspace.shared.open(url)
                            }

                        case .failure:
                            // ❌ 执行失败 / 用户取消
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(command, forType: .string)

                            let alert = NSAlert()
                            alert.messageText = "禁用失败"
                            alert.informativeText = """
                    命令已复制，可在终端手动执行：

                    \(command)
                    """
                            alert.addButton(withTitle: "好")
                            alert.runModal()
                        }
                    } else {
                        // 普通方式
                        Unlocker.unlock(appAt: appURL, with: selectedMethod)
                    }

                case "“xxx”意外退出":
                    Unlocker.unlock(appAt: appURL, withAdvancedMethod: selectedAdvancedMethod)

                case "“xxx软件打开失败”":
                    Unlocker.chmodFixExecutable(in: appURL)

                default:
                    break
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
