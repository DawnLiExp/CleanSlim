//
//  CleanupCompletedView.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import SwiftUI

/// 清理完成视图，显示清理结果和完成按钮
public struct CleanupCompletedView: View {
    /// 缓存扫描视图模型
    @ObservedObject var viewModel: CacheScannerViewModel
    
    /// 当前语言
    @AppStorage("appLanguage") private var language = "en"
    
    /// 完成按钮点击回调
    let onComplete: () -> Void
    
    public init(viewModel: CacheScannerViewModel, onComplete: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 30) // 调整为更小的值
            // 进度动画效果
            CircularProgressView(
                progress: 1.0,
                color: Color.green,
                size: 120,
                showCompletionAnimation: true
            )
            .padding(.bottom, 10)
            
            // 完成标题
            Text(LocalizationHelper.string("cleanup.complete.title"))
                .font(.title)
                .fontWeight(.bold)
            
            // 清理大小信息
            Text(String(format: LocalizationHelper.string("cleanup.complete.message"), viewModel.formattedCleanedSize))
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // 完成按钮
            Button(action: onComplete) {
                Text(LocalizationHelper.string("done"))
                    .font(.headline)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.scanState)
    }
}
