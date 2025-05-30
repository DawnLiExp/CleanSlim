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
            
            // 完成按钮 - 添加悬停效果
            Button(action: onComplete) {
                Text(LocalizationHelper.string("done"))
                    .font(.system(size: 16, weight: .semibold))
            }
            .buttonStyle(HoverButtonStyle(color: .blue))
            .padding(.bottom, 170) // 【参数1】增加底部填充
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // 使用纯色背景，确保完全覆盖主界面
            Rectangle()
                .fill(Color(.windowBackgroundColor))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.bottom) // 【参数2】确保延伸到底部边缘
        )

        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.scanState)
    }
}

/// 悬停按钮样式，提供与AnimatedButton一致的悬停效果
private struct HoverButtonStyle: ButtonStyle {
    let color: Color
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 40) // 【参数3】水平内边距，范围30-50
            .padding(.vertical, 12) // 【参数4】垂直内边距，范围10-15
            .background(isHovered ? color : color.opacity(0.8)) // 【参数5】背景色不透明度，范围0.7-0.9
            .foregroundColor(.white)
            .cornerRadius(9) // 【参数6】圆角半径，范围8-12
            .shadow(
                color: color.opacity(isHovered ? 0.6 : 0.4), // 【参数7】阴影不透明度，范围0.3-0.7
                radius: isHovered ? 8 : 5, // 【参数8】阴影半径，范围4-10
                x: 0,
                y: isHovered ? 4 : 3 // 【参数9】阴影垂直偏移，范围2-5
            )
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovered ? 1.02 : 1.0)) // 【参数10】悬停缩放，范围1.01-1.05
            .animation(.easeInOut(duration: 0.2), value: isHovered) // 【参数11】动画持续时间，范围0.1-0.3
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onHover { hovering in
                self.isHovered = hovering
            }
    }
}
