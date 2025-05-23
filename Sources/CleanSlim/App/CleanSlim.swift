//
//  CleanSlimApp.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/17.
//

import SwiftUI

/// 应用程序入口
@main
public struct CleanSlimApp: App {
    /// 应用程序代理
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// 当前语言
    @AppStorage("appLanguage") private var language = "en"
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainView()
                // 设置本地化环境
                .environment(\.locale, Locale(identifier: language))
                // 设置窗口标题
                .navigationTitle(NSLocalizedString("app.title", comment: "CleanSlim"))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // 添加自定义菜单
            CommandGroup(replacing: .appInfo) {
                Button(NSLocalizedString("about.app", comment: "About CleanSlim")) {
                    appDelegate.showAbout()
                }
            }
            
            CommandGroup(after: .appSettings) {
                Button(NSLocalizedString("scan.now", comment: "Scan Now")) {
                    NotificationCenter.default.post(name: Notification.Name("ScanNowAction"), object: nil)
                }
                
                Divider()
                
                Button(NSLocalizedString("clean.all", comment: "Clean All")) {
                    NotificationCenter.default.post(name: Notification.Name("CleanAllAction"), object: nil)
                }
            }
        }
    }
}
