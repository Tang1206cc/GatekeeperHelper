import Foundation
import SwiftUI
import AppKit

struct DiskImageFixView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("解决方案：未能打开磁盘映像与磁盘映像已过时")
                    .font(.title2)
                    .bold()
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("这是一种mac OS打开某些磁盘映像（dmg）时的报错现象")

                    Text("解决方式如下：")

                    Text("1. command+空格，搜索“磁盘工具”并打开。\n2. 在顶部导航菜单找到“文件”并点击。\n3. 选择“打开磁盘映像”。\n4. 在访达弹窗中选择报错的磁盘映像（dmg）并点击右下角打开。\n5. 之后就可以通过正常方式打开该磁盘映像，若无效可多次重试，一般多打开几次就可以正常使用该映像。")

                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 180)
                        .overlay(
                            Text("【图片占位】")
                                .foregroundColor(.gray)
                        )
                }
                .font(.body)
            }

            Spacer()

            HStack {
                Spacer()

                Button("跳转至磁盘工具") {
                    let url = URL(fileURLWithPath: "/System/Applications/Utilities/Disk Utility.app")
                    NSWorkspace.shared.open(url)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(minWidth: 620, minHeight: 460)
    }
}

