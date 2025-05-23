//
//  ByteCountFormatter+Extension.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//


import SwiftUI

/// 字节格式化扩展，提供文件大小格式化功能
public extension ByteCountFormatter {
    /// 格式化字节数为可读字符串
    /// - Parameter bytes: 字节数
    /// - Returns: 格式化后的字符串，如 "1.2 MB"
    static func string(fromBytes bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: bytes)
    }
}
