//
//  AppDelegate.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/17.
//

import AppKit
import SwiftUI

/// 应用程序代理
class AppDelegate: NSObject, NSApplicationDelegate {
    /// 状态栏项
    private var statusBar: NSStatusItem?
    
    /// 应用程序启动完成
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置应用程序外观
        setupAppearance()
    }
    
    /// 设置应用程序外观
    private func setupAppearance() {
        // 设置窗口样式
        NSWindow.allowsAutomaticWindowTabbing = false
        
        // 设置菜单栏图标
        statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusBar?.button {
            button.image = NSImage(systemSymbolName: "trash.circle", accessibilityDescription: "Cache Cleaner")
        }
        
        // 创建菜单
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: NSLocalizedString("scan.now", comment: "Scan Now"), action: #selector(scanNow), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: NSLocalizedString("clean.all", comment: "Clean All"), action: #selector(cleanAll), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("quit", comment: "Quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusBar?.menu = menu
    }
    
    /// 显示关于窗口
    func showAbout() {
        let alert = NSAlert()
    
        // 获取应用信息
        let appName = NSLocalizedString("app.title", comment: "CleanSlim")
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    
        let versionTitle = NSLocalizedString("version", comment: "Version")
    
        // 设置弹窗内容
        alert.messageText = "\(appName) \(versionTitle) \(version)"
        alert.informativeText = NSLocalizedString("app.description", comment: "A lightweight cache cleaner for macOS")
        alert.addButton(withTitle: NSLocalizedString("ok", comment: "OK"))
        alert.runModal()
    }
    
    /// 扫描操作
    @objc func scanNow() {
        NotificationCenter.default.post(name: Notification.Name("ScanNowAction"), object: nil)
    }
    
    /// 清理操作
    @objc func cleanAll() {
        NotificationCenter.default.post(name: Notification.Name("CleanAllAction"), object: nil)
    }
}
