//
//  LocalizationHelper.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/20.
//

import SwiftUI

/// 本地化辅助工具，提供统一的本地化字符串访问方法
public struct LocalizationHelper {
    /// 当前语言
    @AppStorage("appLanguage") private static var language = "en"
    
    /// 获取本地化字符串
    /// - Parameter key: 字符串键
    /// - Returns: 本地化后的字符串
    public static func string(_ key: String) -> String {
        let bundle = localizationBundle()
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    
    /// 获取当前语言的本地化Bundle
    private static func localizationBundle() -> Bundle {
        // 打印当前语言，便于调试
        // print("当前语言: \(language)")
        
        // 尝试直接从主Bundle获取语言资源
        if let lprojPath = Bundle.main.path(forResource: language, ofType: "lproj") {
            if let lprojBundle = Bundle(path: lprojPath) {
                return lprojBundle
            }
        }
        
        // 尝试从Localization目录获取
        let bundlePath = Bundle.main.path(forResource: language, ofType: "lproj", inDirectory: "Localization")
        if let bundlePath = bundlePath, let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        
        // 尝试获取SPM资源Bundle
        let bundleNames = [
            "CleanSlim_CleanSlim",
            "CleanSlim_Localization"
        ]
        
        for bundleName in bundleNames {
            if let resourceBundleURL = Bundle.main.url(forResource: bundleName, withExtension: "bundle"),
               let resourceBundle = Bundle(url: resourceBundleURL) {
                // 尝试从资源包中获取语言资源
                if let lprojPath = resourceBundle.path(forResource: language, ofType: "lproj") {
                    if let lprojBundle = Bundle(path: lprojPath) {
                        return lprojBundle
                    }
                }
                
                // 如果找不到特定语言，尝试直接从资源包获取
                return resourceBundle
            }
        }
        
        // 尝试特殊处理中文
        if language == "zh-Hans" {
            // 尝试其他可能的中文目录名
            let chineseVariants = ["zh", "zh_CN", "zh-CN", "zh_Hans", "zh-Hans_CN"]
            
            for variant in chineseVariants {
                if let lprojPath = Bundle.main.path(forResource: variant, ofType: "lproj") {
                    if let lprojBundle = Bundle(path: lprojPath) {
                        return lprojBundle
                    }
                }
                
                // 尝试从Localization目录获取
                let bundlePath = Bundle.main.path(forResource: variant, ofType: "lproj", inDirectory: "Localization")
                if let bundlePath = bundlePath, let bundle = Bundle(path: bundlePath) {
                    return bundle
                }
                
                // 尝试从SPM资源包获取
                for bundleName in bundleNames {
                    if let resourceBundleURL = Bundle.main.url(forResource: bundleName, withExtension: "bundle"),
                       let resourceBundle = Bundle(url: resourceBundleURL) {
                        if let lprojPath = resourceBundle.path(forResource: variant, ofType: "lproj") {
                            if let lprojBundle = Bundle(path: lprojPath) {
                                return lprojBundle
                            }
                        }
                    }
                }
            }
        }
        
        // 回退到主Bundle
        return Bundle.main
    }
    
    /// 切换语言
    public static func switchLanguage(to newLanguage: String) {
        language = newLanguage
    }
}
