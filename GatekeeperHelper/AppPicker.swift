//
//  AppPicker.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/24.
//

import Foundation
import AppKit

struct AppPicker {
    static func chooseApp() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]

        if panel.runModal() == .OK {
            return panel.url
        } else {
            return nil
        }
    }
}
