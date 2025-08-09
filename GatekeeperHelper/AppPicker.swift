//
//  AppPicker.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/24.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

struct AppPicker {
    static func chooseApp(allowedExtensions: [String] = ["app"]) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = allowedExtensions.compactMap { UTType(filenameExtension: $0) }
        } else {
            panel.allowedFileTypes = allowedExtensions
        }

        if panel.runModal() == .OK {
            return panel.url
        } else {
            return nil
        }
    }
}
