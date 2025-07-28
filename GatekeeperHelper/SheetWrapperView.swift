// SheetWrapperView.swift
import SwiftUI

struct SheetWrapperView: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if title.contains("捐赠") {
                    // ✅ 捐赠弹窗内容
                    VStack(spacing: 16) {
                        Text("感谢您的支持 ❤️")
                            .font(.title2)
                            .bold()
                            .padding(.top, 16)

                        Text("""
                        您的鼓励是我持续优化 GatekeeperHelper 的最大动力！

                        如果这个工具对您有所帮助，欢迎通过以下方式打赏支持。
                        """)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                        HStack(spacing: 32) {
                            VStack(spacing: 8) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Text("微信")
                                            .foregroundColor(.gray)
                                    )
                                Text("微信")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(spacing: 8) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Text("支付宝")
                                            .foregroundColor(.gray)
                                    )
                                Text("支付宝")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)

                        Spacer(minLength: 12)
                    }
                } else if title.contains("联系") {
                    // ✅ 联系&反馈弹窗内容
                    VStack(spacing: 20) {
                        Text("联系与反馈")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)

                        Text("如果您有任何建议或意见，欢迎通过下面的方式联系作者或加入讨论。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("📧 邮箱：")
                                    .bold()
                                Text("1767707905@qq.com")
                                    .foregroundColor(.primary)
                            }

                            HStack {
                                Text("💬 官方讨论 Q 群：")
                                    .bold()
                                Text("850780538")
                                    .foregroundColor(.primary)
                            }
                        }
                        .font(.body)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        Spacer()
                    }
                } else {
                    // ✅ 其他通用弹窗内容（保留）
                    VStack(alignment: .leading, spacing: 16) {
                        Text(title)
                            .font(.title3)
                            .bold()

                        Spacer()
                    }
                    .padding()
                }
            }
            .frame(width: 420, height: 360)
            .background(Color(NSColor.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 通用关闭按钮
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .imageScale(.large)
                    .padding(10)
            }
            .buttonStyle(.plain)
        }
    }
}
