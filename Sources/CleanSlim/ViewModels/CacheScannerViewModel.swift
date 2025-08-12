//
//  CacheScannerViewModel.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import Combine
import Foundation

/// UserDefaults键常量
private let kCategorySelectionsKey = "com.macoscachecleaner.categorySelections"

/// 最小清理动画持续时间（秒）
private let kMinCleanAnimationDuration: TimeInterval = 0.8 // 【参数1】可调整，范围1.0-5.0秒

/// 缓存扫描器视图模型，处理缓存扫描和清理的业务逻辑
public class CacheScannerViewModel: ObservableObject {
    /// 扫描状态
    public enum ScanState {
        case idle // 空闲状态
        case scanning // 扫描中
        case scanned // 扫描完成
        case cleaning // 清理中
        case completed // 清理完成
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

        // 从UserDefaults加载保存的勾选状态
        loadSavedSelections()

        // 监听通知
        setupNotifications()
    }

    /// 从UserDefaults加载保存的勾选状态
    private func loadSavedSelections() {
        // 获取保存的选中状态字典
        if let savedSelections = UserDefaults.standard.dictionary(forKey: kCategorySelectionsKey) as? [String: Bool] {
            // 应用保存的选中状态
            for i in 0..<categories.count {
                if let isSelected = savedSelections[categories[i].name] {
                    categories[i].isSelected = isSelected
                }
            }
        }
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

        // 保存选中状态
        saveCategorySelections()
    }

    /// 切换全选状态
    public func toggleAllSelection() {
        let newValue = !isAllSelected

        // 更新所有分类的选中状态
        for i in 0..<categories.count {
            categories[i].isSelected = newValue
        }

        // 保存选中状态
        saveCategorySelections()
    }

    /// 保存分类勾选状态到UserDefaults
    private func saveCategorySelections() {
        // 创建包含分类名称和选中状态的字典
        let selectionsDict = categories.reduce(into: [String: Bool]()) { dict, category in
            dict[category.name] = category.isSelected
        }

        // 保存到UserDefaults
        UserDefaults.standard.set(selectionsDict, forKey: kCategorySelectionsKey)
    }

    /// 清理选中的缓存
    public func cleanSelectedCaches() {
        // 检查是否有选中的分类
        let selectedCategories = categories.filter { $0.isSelected }
        guard !selectedCategories.isEmpty else { return }

        // 更新状态
        scanState = .cleaning
        cleanProgress = 0.0
        
        // 记录开始时间
        let startTime = Date()

        // 清理选中的缓存目录
        cacheCleanerService.cleanSelectedCacheDirectories(categories: categories, progress: { progress in
            self.cleanProgress = progress
        }, completion: { cleanedSize in
            // 更新已清理的大小
            self.cleanedSize = cleanedSize
            
            // 计算已经过的时间
            let elapsedTime = Date().timeIntervalSince(startTime)
            
            // 如果清理时间不足最小动画时间，添加延迟
            if elapsedTime < kMinCleanAnimationDuration {
                // 计算需要额外延迟的时间
                let delayTime = kMinCleanAnimationDuration - elapsedTime
                
                // 在延迟期间，平滑过渡到100%进度
                let remainingProgress = 1.0 - self.cleanProgress
                let progressUpdateInterval = 0.05 // 【参数2】更新间隔，范围0.01-0.1秒
                let progressSteps = Int(delayTime / progressUpdateInterval)
                let progressIncrement = remainingProgress / Double(max(progressSteps, 1))
                
                // 创建定时器平滑更新进度
                var currentStep = 0
                Timer.scheduledTimer(withTimeInterval: progressUpdateInterval, repeats: true) { timer in
                    currentStep += 1
                    DispatchQueue.main.async {
                        // 计算新进度，确保不超过1.0
                        let newProgress = min(self.cleanProgress + (progressIncrement * Double(currentStep)), 1.0)
                        self.cleanProgress = newProgress
                    }
                    
                    // 达到步数或进度为1.0时停止定时器
                    if currentStep >= progressSteps || self.cleanProgress >= 1.0 {
                        timer.invalidate()
                    }
                }
                
                // 延迟后再切换到完成状态
                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime + 0.2) {
              //  DispatchQueue.main.asyncAfter(deadline: .now() + delayTime + 0.1) { // 【参数6】额外增加0.2-0.5秒延迟
                    // 更新状态为完成
                    self.scanState = .completed
                }
            } else {
                // 清理时间已经超过最小动画时间，直接切换到完成状态
                self.scanState = .completed
            }
        })
    }

    /// 重置到扫描状态
    public func resetToScanState() {
        // 重置状态
        scanState = .idle

        // 重新开始扫描
        startScan()
    }
}
