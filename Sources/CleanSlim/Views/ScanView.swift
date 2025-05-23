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
            
            // 扫描进度环
            CircularProgressView(
                progress: viewModel.scanProgress,
                color: Color.blue,
                size: 100
            )
            .padding(.bottom, 20)
            
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
                isLoading: viewModel.scanState == .scanning
            )
            .padding(.bottom, 40)
        }
    }
}
