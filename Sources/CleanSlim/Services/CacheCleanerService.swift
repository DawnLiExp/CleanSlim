//
//  CacheCleanerService.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import Combine
import Foundation

/// 缓存清理服务，提供缓存扫描和清理功能
public class CacheCleanerService {
    /// 缓存目录列表
    private let cacheDirectories: [URL]
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    /// 初始化缓存清理服务
    /// - Parameter cacheDirectories: 缓存目录列表
    public init(cacheDirectories: [URL]) {
        self.cacheDirectories = cacheDirectories
    }
    
    /// 获取缓存分类列表
    /// - Returns: 缓存分类列表
    public func getCacheCategories() -> [CacheCategory] {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        
        // 创建缓存分类
        let categories = [
            CacheCategory(
                name: "system.cache",
                iconName: "square.3.layers.3d.top.filled",
                path: homeDirectory.appendingPathComponent("Library/Caches")
            ),
            CacheCategory(
                name: "xcode.cache",
                iconName: "hammer.fill",
                path: homeDirectory.appendingPathComponent("Library/Developer/Xcode/DerivedData")
            ),
            CacheCategory(
                name: "system.logs",
                iconName: "doc.text.fill",
                path: homeDirectory.appendingPathComponent("Library/Logs")
            ),
            CacheCategory(
                name: "temp.cache", // 标识临时文件缓存
                iconName: "trash.fill", // 使用系统垃圾桶图标（SF Symbols）
                path: URL(fileURLWithPath: "/private/var/folders/vf/cs4l7qys3n7dd5c8r1q2sq400000gn/T/", isDirectory: true) // 明确标记为目录
            ),
            CacheCategory(
                name: "app.state",
                iconName: "folder.fill.badge.gearshape",
                path: homeDirectory.appendingPathComponent("Library/Saved Application State")
            ),
            CacheCategory(
                name: "test.cache", // 分类标识
                iconName: "folder.fill.badge.plus", // 使用外置磁盘图标
                path: URL(fileURLWithPath: "/Volumes/Store/output/tmp/") // 绝对路径
            )
        ]
        
        return categories
    }
    
    /// 扫描缓存目录
    /// - Parameters:
    ///   - categories: 缓存分类列表
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    public func scanCacheDirectories(categories: [CacheCategory], progress: @escaping (Double) -> Void, completion: @escaping ([CacheCategory]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var updatedCategories = categories
            let totalCategories = categories.count
            
            // 遍历缓存分类
            for (index, category) in categories.enumerated() {
                // 检查目录是否存在
                if self.fileManager.fileExists(atPath: category.path.path) {
                    // 获取目录大小
                    let size = self.fileManager.directorySize(at: category.path)
                    
                    // 获取文件数量
                    let fileCount = self.fileManager.fileCount(at: category.path)
                    
                    // 更新分类信息
                    updatedCategories[index].size = size
                    updatedCategories[index].fileCount = fileCount
                }
                // 添加延时以延长Scan动画效果
                 Thread.sleep(forTimeInterval: 0.04)
                // 更新进度
                let currentProgress = Double(index + 1) / Double(totalCategories)
                DispatchQueue.main.async {
                    progress(currentProgress)
                }
            }
            
            // 完成回调
            DispatchQueue.main.async {
                completion(updatedCategories)
            }
        }
    }
    
    /// 清理选中的缓存目录
    /// - Parameters:
    ///   - categories: 缓存分类列表
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    public func cleanSelectedCacheDirectories(categories: [CacheCategory], progress: @escaping (Double) -> Void, completion: @escaping (Int64) -> Void) {
        // 获取选中的分类
        let selectedCategories = categories.filter { $0.isSelected }
        let totalCategories = selectedCategories.count
        
        if totalCategories == 0 {
            DispatchQueue.main.async {
                progress(1.0)
                completion(0)
            }
            return
        }
        
        // 计算总大小
        let totalSize = selectedCategories.reduce(0) { $0 + $1.size }
        var cleanedSize: Int64 = 0
        var completedCategories = 0
        
        // 遍历清理选中的分类
        for category in selectedCategories {
            self.fileManager.cleanDirectory(at: category.path, progress: { categoryProgress in
                // 计算总进度
                let categoryWeight = Double(category.size) / Double(totalSize)
                let overallProgress = (Double(completedCategories) / Double(totalCategories)) + (categoryProgress * categoryWeight)
                
                DispatchQueue.main.async {
                    progress(overallProgress)
                }
            }, completion: { error in
                completedCategories += 1
                
                if error == nil {
                    cleanedSize += category.size
                }
                
                // 检查是否所有分类都已处理
                if completedCategories == totalCategories {
                    DispatchQueue.main.async {
                        progress(1.0)
                        completion(cleanedSize)
                    }
                }
            })
        }
    }
}
