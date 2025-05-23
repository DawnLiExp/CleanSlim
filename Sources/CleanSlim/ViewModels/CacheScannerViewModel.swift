//
//  CacheScannerViewModel.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//


import Foundation
import Combine

/// 缓存扫描器视图模型，处理缓存扫描和清理的业务逻辑
public class CacheScannerViewModel: ObservableObject {
    /// 扫描状态
    public enum ScanState {
        case idle       // 空闲状态
        case scanning   // 扫描中
        case scanned    // 扫描完成
        case cleaning   // 清理中
        case completed  // 清理完成
    }
    
    /// 缓存清理服务
    private let cacheCleanerService: CacheCleanerService
    
    /// 取消令牌
    private var cancellables = Set<AnyCancellable>()
    
    /// 当前扫描状态
    @Published public var scanState: ScanState = .idle
    
    /// 缓存分类列表
    @Published public var categories: [CacheCategory] = []
    
    /// 扫描进度 (0.0 - 1.0)
    @Published public var scanProgress: Double = 0.0
    
    /// 清理进度 (0.0 - 1.0)
    @Published public var cleanProgress: Double = 0.0
    
    /// 总缓存大小
    @Published public var totalCacheSize: Int64 = 0
    
    /// 已清理的缓存大小
    @Published public var cleanedSize: Int64 = 0
    
    /// 是否全部选中
    public var isAllSelected: Bool {
        return categories.allSatisfy { $0.isSelected }
    }
    
    /// 格式化的总缓存大小
    public var formattedTotalSize: String {
        return ByteCountFormatter.string(fromBytes: totalCacheSize)
    }
    
    /// 格式化的已清理缓存大小
    public var formattedCleanedSize: String {
        return ByteCountFormatter.string(fromBytes: cleanedSize)
    }
    
    /// 初始化视图模型
    public init() {
        // 初始化缓存清理服务
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let cacheDirectories = [
            homeDirectory.appendingPathComponent("Library/Caches"),
            homeDirectory.appendingPathComponent("Library/Developer/Xcode/DerivedData"),
            homeDirectory.appendingPathComponent("Library/Logs"),
            homeDirectory.appendingPathComponent("Library/Saved Application State")
        ]
        
        self.cacheCleanerService = CacheCleanerService(cacheDirectories: cacheDirectories)
        
        // 初始化缓存分类
        self.categories = cacheCleanerService.getCacheCategories()
        
        // 监听通知
        setupNotifications()
    }
    
    /// 设置通知监听
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: Notification.Name("ScanNowAction"))
            .sink { [weak self] _ in
                self?.startScan()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name("CleanAllAction"))
            .sink { [weak self] _ in
                guard let self = self, self.scanState == .scanned else { return }
                
                // 全选并清理
                for i in 0..<self.categories.count {
                    self.categories[i].isSelected = true
                }
                
                self.cleanSelectedCaches()
            }
            .store(in: &cancellables)
    }
    
    /// 开始扫描缓存
    public func startScan() {
        // 检查是否正在扫描或清理
        guard scanState != .scanning && scanState != .cleaning else { return }
        
        // 更新状态
        scanState = .scanning
        scanProgress = 0.0
        totalCacheSize = 0
        
        // 扫描缓存目录
        cacheCleanerService.scanCacheDirectories(categories: categories, progress: { progress in
            self.scanProgress = progress
        }, completion: { updatedCategories in
            // 更新分类列表
            self.categories = updatedCategories
            
            // 计算总大小
            self.totalCacheSize = updatedCategories.reduce(0) { $0 + $1.size }
            
            // 更新状态
            self.scanState = .scanned
        })
    }
    
    /// 切换分类选中状态
    /// - Parameter category: 缓存分类
    public func toggleCategorySelection(_ category: CacheCategory) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        
        // 切换选中状态
        categories[index].isSelected.toggle()
    }
    
    /// 切换全选状态
    public func toggleAllSelection() {
        let newValue = !isAllSelected
        
        // 更新所有分类的选中状态
        for i in 0..<categories.count {
            categories[i].isSelected = newValue
        }
    }
    
    /// 清理选中的缓存
    public func cleanSelectedCaches() {
        // 检查是否有选中的分类
        let selectedCategories = categories.filter { $0.isSelected }
        guard !selectedCategories.isEmpty else { return }
        
        // 更新状态
        scanState = .cleaning
        cleanProgress = 0.0
        
        // 清理选中的缓存目录
        cacheCleanerService.cleanSelectedCacheDirectories(categories: categories, progress: { progress in
            self.cleanProgress = progress
        }, completion: { cleanedSize in
            // 更新已清理的大小
            self.cleanedSize = cleanedSize
            
            // 更新状态为完成（不再自动重新扫描）
            self.scanState = .completed
        })
    }
    
    /// 重置到扫描状态
    public func resetToScanState() {
        // 重置状态
        self.scanState = .idle
        
        // 重新开始扫描
        self.startScan()
    }
}
