//
//  MainView.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import SwiftUI

/// 主视图，应用程序的主界面
public struct MainView: View {
    /// 缓存扫描视图模型
    @StateObject private var viewModel = CacheScannerViewModel()
    
    /// 当前语言
    @AppStorage("appLanguage") private var language = "en"
    
    /// 强制刷新视图的状态
    @State private var refreshView = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            // 顶部区域
            headerView
            
            // 中间区域 - 分类卡片
            ScrollView {
                if viewModel.scanState == .idle || viewModel.scanState == .scanning {
                    // 扫描视图
                    ScanView(viewModel: viewModel)
                        .padding(.horizontal)
                } else if viewModel.scanState == .scanned {
                    // 分类视图
                    CategoryView(viewModel: viewModel)
                } else if viewModel.scanState == .completed {
                    // 清理完成视图 - 全屏显示
                    CleanupCompletedView(viewModel: viewModel) {
                        // 点击完成按钮后返回主界面
                        viewModel.resetToScanState()
                    }
                }
            }
            
            // 底部区域 - 清理进度
            if viewModel.scanState == .cleaning {
                ProgressView(
                    progress: viewModel.cleanProgress,
                    statusText: LocalizationHelper.string("cleaning"),
                    color: Color.green
                )
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding(.vertical)
        .frame(minWidth: 580, minHeight: 650)
        .background(Color(.windowBackgroundColor))
        .id(refreshView) // 使用id强制刷新视图
        .onAppear {
            // 应用启动时自动扫描
            viewModel.startScan()
        }
    }
    
    /// 顶部区域视图
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // 应用标题
                HStack(spacing: 3) {
                    Text(LocalizationHelper.string("app.title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    if let iconImage = Bundle.cleanSlimModule.image(named: "icon") {
                        Image(nsImage: iconImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                }
                Spacer()
                
                // 语言切换
                Picker("", selection: $language) {
                    Text("🇺🇸").tag("en")
                    Text("🇨🇳").tag("zh-Hans")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 100)
                .onChange(of: language) { newValue in
                    // 切换语言时强制刷新视图
                    LocalizationHelper.switchLanguage(to: newValue)
                    refreshView.toggle()
                }
            }
            .padding(.horizontal)
            
            // 总缓存大小显示
            VStack(spacing: 8) {
                HStack {
                    Text(LocalizationHelper.string("total.cache.size"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                
                    Spacer()
                
                    Text(viewModel.formattedTotalSize)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                }
                .padding(.horizontal)
            
                Divider()
                    .padding(.horizontal)
            }
        }
    }
}
