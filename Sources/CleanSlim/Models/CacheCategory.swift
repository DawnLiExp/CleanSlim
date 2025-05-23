//
//  CacheCategory.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import Foundation

/// 表示缓存分类的模型
public struct CacheCategory: Identifiable {

    public let id = UUID()
    
    public let name: String
    
    public let iconName: String
    
    /// 缓存目录路径
    public let path: URL
    
    /// 缓存大小（字节）
    public var size: Int64 = 0
    
    /// 文件数量
    public var fileCount: Int = 0
    
    /// 是否选中
    public var isSelected: Bool = true
    
    /// 本地化名称
    public var localizedName: String {
        return NSLocalizedString(name, comment: name)
    }
    
    /// 格式化的缓存大小
    public var formattedSize: String {
        return ByteCountFormatter.string(fromBytes: size)
    }
    
    public init(name: String, iconName: String, path: URL) {
        self.name = name
        self.iconName = iconName
        self.path = path
    }
}
