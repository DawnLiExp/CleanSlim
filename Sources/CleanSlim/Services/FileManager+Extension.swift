//
//  FileManager+Extension.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//


import Foundation
import Combine

/// 文件管理器扩展，提供缓存文件操作功能
public extension FileManager {
    /// 获取目录大小
    /// - Parameter url: 目录URL
    /// - Returns: 目录大小（字节）
    func directorySize(at url: URL) -> Int64 {
        let keys: Set<URLResourceKey> = [.isRegularFileKey, .fileAllocatedSizeKey, .totalFileAllocatedSizeKey]
        
        // 获取目录内容
        guard let enumerator = self.enumerator(at: url, includingPropertiesForKeys: Array(keys), options: [], errorHandler: { _, _ in true }) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        
        // 遍历目录内容
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: keys),
                  let isRegularFile = resourceValues.isRegularFile,
                  isRegularFile else {
                continue
            }
            
            // 获取文件大小
            if let fileSize = resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
    
    /// 获取目录文件数量
    /// - Parameter url: 目录URL
    /// - Returns: 文件数量
    func fileCount(at url: URL) -> Int {
        guard let enumerator = self.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [], errorHandler: { _, _ in true }) else {
            return 0
        }
        
        var count = 0
        
        // 遍历目录内容
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                  let isRegularFile = resourceValues.isRegularFile,
                  isRegularFile else {
                continue
            }
            
            count += 1
        }
        
        return count
    }
    
    /// 清理目录内容
    /// - Parameters:
    ///   - url: 目录URL
    ///   - progress: 进度回调
    ///   - completion: 完成回调
    func cleanDirectory(at url: URL, progress: @escaping (Double) -> Void, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 获取目录内容
                let contents = try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                let totalCount = contents.count
                
                if totalCount == 0 {
                    DispatchQueue.main.async {
                        progress(1.0)
                        completion(nil)
                    }
                    return
                }
                
                // 遍历删除文件
                for (index, fileURL) in contents.enumerated() {
                    do {
                        try self.removeItem(at: fileURL)
                    } catch {
                        // 忽略正在使用的文件
                        print("无法删除文件: \(fileURL.path), 错误: \(error.localizedDescription)")
                    }
                    
                    // 更新进度
                    let currentProgress = Double(index + 1) / Double(totalCount)
                    DispatchQueue.main.async {
                        progress(currentProgress)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}
