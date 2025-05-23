//
//  CacheItem.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//


import Foundation

// 表示单个缓存项
public struct CacheItem: Identifiable {

    public let id = UUID()
    
    public let path: URL
    
    public let size: Int64
    
    public var name: String {
        return path.lastPathComponent
    }
    
    /// 格式化的文件大小
    public var formattedSize: String {
        return ByteCountFormatter.string(fromBytes: size)
    }
    
    public init(path: URL, size: Int64) {
        self.path = path
        self.size = size
    }
}
