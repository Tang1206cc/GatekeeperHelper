//
//  CloseSIPSheetView.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/28.
//

import Foundation
import SwiftUI

struct CloseSIPSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 顶部标题
            HStack {
                Text("⚠️ 非必要请勿关闭 SIP")
                    .font(.title2).bold()
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("什么是 SIP？")
                            .font(.headline)

                        Text("""
系统完整性保护（System Integrity Protection，简称 SIP）是 Apple 自 macOS El Capitan（10.11）起引入的一项安全机制，旨在防止恶意软件修改系统关键文件和进程，从而增强系统稳定性与安全性。
""")
                    }

                    Group {
                        Text("为什么要关闭 SIP？")
                            .font(.headline)

                        Text("""
某些特定 App 由于签名问题或需要访问系统受限区域，若 SIP 开启可能导致功能受限、闪退或无法启动。此时用户需暂时关闭 SIP，执行某些终端命令后再重新开启。
""")
                    }

                    Group {
                        Text("如何判断当前是否已关闭 SIP？")
                            .font(.headline)

                        Text("打开「终端」，执行以下命令：")

                        CodeBlockView(command: "csrutil status")

                        Text("若输出包含 `enabled` 则 SIP 已开启；包含 `disabled` 则为已关闭状态。")
                    }

                    Group {
                        Text("如何关闭 SIP？")
                            .font(.headline)

                        Text("请按照以下步骤操作：")

                        VStack(alignment: .leading, spacing: 10) {
                            Text("① 重启进入恢复模式：")

                            Text("• Intel 机型：重启并长按 ⌘ + R")
                            Text("• Apple Silicon：关机后长按电源键 → 进入“选项”")

                            Text("② 打开顶部菜单的“实用工具” → 选择“终端”")

                            Text("③ 输入以下命令并回车：")
                            CodeBlockView(command: "csrutil disable")

                            Text("④ 重启电脑：")
                            CodeBlockView(command: "reboot")
                        }
                    }

                    Group {
                        Text("如何重新开启 SIP？")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("步骤与关闭类似，只需将命令替换为：")
                            CodeBlockView(command: "csrutil enable")
                        }
                    }

                    Group {
                        Text("温馨提示")
                            .font(.headline)

                        Text("""
关闭 SIP 会降低系统安全性，若非 App 明确提示或遇到必须处理的问题，请勿关闭。大多数常规绕过方法（如 xattr 或签名）不需要关闭 SIP。
""")
                        .foregroundColor(.orange)
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(minWidth: 580, minHeight: 500)
    }
}

// MARK: - 可复制的代码块组件
struct CodeBlockView: View {
    let command: String
    @State private var copied = false

    var body: some View {
        HStack {
            Text(command)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(6)
                .contextMenu {
                    Button("复制") {
                        copyToClipboard()
                    }
                }

            Spacer()

            Button(action: {
                copyToClipboard()
            }) {
                Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .help("复制命令")
        }
        .onChange(of: copied) { _ in
            if copied {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    copied = false
                }
            }
        }
    }

    func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
        copied = true
    }
}
