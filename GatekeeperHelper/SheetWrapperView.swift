// SheetWrapperView.swift
import SwiftUI

struct SheetWrapperView: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title3)
                    .bold()

                Spacer()
            }
            .padding()
            .frame(width: 420, height: 220)

            // 👇浮动的右上角 X 按钮
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
