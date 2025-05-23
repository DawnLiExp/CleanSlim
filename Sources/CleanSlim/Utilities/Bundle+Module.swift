//
//  Bundle+Module.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/22.
//

import AppKit

public extension Bundle {
    static var cleanSlimModule: Bundle {
        // 尝试从 .app 的 Resources 中加载 SwiftPM bundle
        if let url = Bundle.main.url(forResource: "CleanSlim_CleanSlim", withExtension: "bundle"),
           let bundle = Bundle(url: url)
        {
            return bundle
        }

        // fallback for Xcode debug
        return .module
    }

    func image(named name: String) -> NSImage? {
        return self.url(forResource: name, withExtension: "png").flatMap { NSImage(contentsOf: $0) }
    }
}
