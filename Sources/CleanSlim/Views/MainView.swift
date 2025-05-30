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
        .background(
            ZStack {
                // 渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.windowBackgroundColor),
                        Color(.windowBackgroundColor).opacity(0.98),
                        Color(.windowBackgroundColor)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
        
                // 微妙的装饰元素 - 可调整参数
                ZStack {
                    // 左上角装饰 - 增强效果
                    Circle()
                        .fill(Color.blue.opacity(0.08)) // 【参数1】增加不透明度，范围0.05-0.15
                        .frame(width: 220, height: 220) // 【参数2】增加尺寸，范围180-250
                        .offset(x: -60, y: -60)
                        .blur(radius: 50) // 【参数3】调整模糊半径，范围30-60
            
                    // 右下角装饰 - 增强效果
                    Circle()
                        .fill(Color.purple.opacity(0.09)) // 【参数4】增加不透明度，范围0.05-0.15
                        .frame(width: 280, height: 280) // 【参数5】增加尺寸，范围220-300
                        .offset(x: 130, y: 100)
                        .blur(radius: 60) // 【参数6】调整模糊半径，范围40-70
            
                    // 中部装饰
                    // Circle()
                    //    .fill(Color.green.opacity(0.1)) // 【参数7】调整不透明度，范围0.04-0.12
                    //    .frame(width: 120, height: 150) // 【参数8】调整尺寸，范围150-250
                    //    .offset(x: 100, y: -310) // 【参数9】调整位置
                    //    .blur(radius: 15) // 【参数10】调整模糊半径，范围40-70
                }
            }
        )

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
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.primary,
                                    Color.primary.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    if let iconImage = Bundle.cleanSlimModule.image(named: "icon") {
                        Image(nsImage: iconImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                }

                Spacer() // 确保标题和语言切换分开
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
