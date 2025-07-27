//
//  ContentView.swift
//  GatekeeperHelper
//

import SwiftUI
import AppKit

enum UnlockMethod: CaseIterable {
    case xattr
    case spctl

    var description: String {
        switch self {
        case .xattr: return "临时绕过（推荐）"
        case .spctl: return "永久禁用 Gatekeeper（危险）"
        }
    }
}

struct UnlockIssue: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

let knownIssues: [UnlockIssue] = [
    UnlockIssue(
        title: "“xxx已损坏，无法打开。您应该推出磁盘映像/移到废纸篓”",
        description: "macOS 的 Gatekeeper 安全机制阻止了该应用打开。您可以选择临时绕过（推荐，仅解除当前 App 的限制），或永久禁用 Gatekeeper（不推荐，会降低系统安全性）。",
        imageName: "issue1-placeholder"
    ),
    UnlockIssue(
        title: "“xxx”意外退出",
        description: "Apple 会定期发布安全补丁，吊销一些“特定”的数字签名。在没有证书的情况下运行应用程序会导致错误消息，并且应用程序意外退出。所以需要对应用进行签名，有时也需要关闭 SIP。",
        imageName: "issue2-placeholder"
    )
]

struct ContentView: View {
    @State private var selectedIssue: UnlockIssue? = knownIssues.first
    @State private var selectedAppURL: URL? = nil
    @State private var selectedUnlockMethod: UnlockMethod = .xattr

    // 弹窗控制
    @State private var showSIPSheet = false
    @State private var showDonateSheet = false
    @State private var showFeedbackSheet = false
    @State private var showSettingsSheet = false
    @State private var showHistorySheet = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 顶部栏：标题 + 功能按钮
                HStack(alignment: .center) {
                    Text("请选择您遇到的 App 启动问题")
                        .font(SwiftUI.Font.title2)
                        .bold()
                        .frame(height: 28)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    Button("历史记录") {
                        showHistorySheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.trailing, 4)

                    HStack(spacing: 8) {
                        Button("捐赠作者") { showDonateSheet = true }
                        Button("联系&反馈") { showFeedbackSheet = true }
                        Button(action: {
                            NSApp.sendAction(#selector(AppDelegate.showPreferencesWindow(_:)), to: nil, from: nil)
                        }) {
                            Image(systemName: "gear")
                                .imageScale(.medium)
                        }
                    }
                    .font(.system(size: 13))
                    .buttonStyle(.plain)
                    .padding(.horizontal, 6)
                }
                .frame(height: 40)
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Divider()

                // 主内容区域
                HStack(spacing: 0) {
                    // 左侧问题导航栏
                    List(selection: $selectedIssue) {
                        ForEach(knownIssues) { issue in
                            Text(issue.title)
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedIssue == issue ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                                .contentShape(Rectangle())
                                .tag(issue)
                        }
                    }
                    .frame(minWidth: 280)
                    .listStyle(SidebarListStyle())

                    Divider()

                    // 右侧详情区域
                    VStack(alignment: .leading, spacing: 16) {
                        if let issue = selectedIssue {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(issue.title)
                                    .font(.title2)
                                    .bold()
                                    .layoutPriority(1)

                                Text(issue.description)
                                    .font(.body)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 150)
                                    .overlay(
                                        Text("【图片占位：\(issue.imageName)】")
                                            .foregroundColor(.gray)
                                    )

                                Divider()

                                DropAreaView { url in
                                    selectedAppURL = url
                                    print("用户拖入或选择的 App 路径：\(url.path)")
                                }
                                .frame(height: 180)
                                .padding(.top, 10)
                                .sheet(item: $selectedAppURL) { url in
                                    FixAppModalView(appURL: url, issue: selectedIssue ?? knownIssues[0], selectedMethod: $selectedUnlockMethod)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("请选择左侧的问题类型")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // ✅ 底部关闭 SIP 提示区域
                        HStack {
                            Spacer()
                            Text("如果这些都没用，请点击：")
                                .foregroundColor(.secondary)
                            Button("关闭 SIP") {
                                showSIPSheet = true
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                    }
                    .padding()
                }
            }
            .frame(minWidth: 960, minHeight: 640)
        }
        // 弹窗内容
        .sheet(isPresented: $showSIPSheet) {
            SheetWrapperView(title: "关闭 SIP 的弹窗内容（待补充）") {
                showSIPSheet = false
            }
        }
        .sheet(isPresented: $showDonateSheet) {
            SheetWrapperView(title: "感谢您支持开发者！（内容待补充）") {
                showDonateSheet = false
            }
        }
        .sheet(isPresented: $showFeedbackSheet) {
            SheetWrapperView(title: "反馈入口（内容待补充）") {
                showFeedbackSheet = false
            }
        }
        .sheet(isPresented: $showHistorySheet) {
            HistorySheetView()
        }
        .sheet(isPresented: $showSettingsSheet) {
            SheetWrapperView(title: "设置界面（内容待补充）") {
                showSettingsSheet = false
            }
        }
    }
}
