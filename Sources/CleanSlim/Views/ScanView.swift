//
//  ScanView.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import SwiftUI

/// 扫描视图，显示扫描进度和状态
public struct ScanView: View {
    /// 缓存扫描视图模型
    @ObservedObject var viewModel: CacheScannerViewModel

    public init(viewModel: CacheScannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // 进度环 - 根据状态显示扫描或清理进度
            CircularProgressView(
                progress: viewModel.scanState == .cleaning ? viewModel.cleanProgress : viewModel.scanProgress,
                color: Color.blue,
                size: 100,
                showCompletionAnimation: viewModel.scanState != .cleaning // 清理状态下不显示完成动画
            )
            .padding(.bottom, 20)
            // 扫描界面圆环背景 - 完全重写为渐变叠加方案
            .overlay(
                ZStack {
                    // 基础圆形背景 - 无边界
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.08), // 【参数11】中心颜色不透明度，范围0.05-0.15
                            Color.blue.opacity(0.01), // 【参数12】边缘颜色不透明度，范围0.005-0.03
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 10, // 【参数13】内圆半径，范围5-20
                        endRadius: 150 // 【参数14】外圆半径，范围120-180
                    )
                    .frame(width: 300, height: 300) // 【参数15】整体尺寸，应大于外圆半径*2
                }
            )

            // 扫描状态文本
            Text(LocalizationHelper.string("scanning"))
                .font(.title2)
                .foregroundColor(.secondary)

            Spacer()

            // 扫描按钮 - 修复参数匹配问题
            AnimatedButton(
                title: LocalizationHelper.string("scan"),
                iconName: "arrow.clockwise",
                color: .blue,
                action: {
                    viewModel.startScan()
                },
                isLoading: viewModel.scanState == .scanning,
                animationDuration: 1.6
            )
            .padding(.bottom, 40)
        }
    }
}
