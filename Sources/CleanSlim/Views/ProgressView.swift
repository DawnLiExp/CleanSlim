//
//  ProgressView.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//


import SwiftUI

/// 进度显示组件，显示清理进度和结果
public struct ProgressView: View {
    /// 进度值 (0.0 - 1.0)
    let progress: Double
    
    /// 状态文本
    let statusText: String
    
    /// 颜色
    let color: Color
    
    /// 是否显示完成动画
    var showCompletionAnimation: Bool = true
    
    public init(progress: Double, statusText: String, color: Color, showCompletionAnimation: Bool = true) {
        self.progress = progress
        self.statusText = statusText
        self.color = color
        self.showCompletionAnimation = showCompletionAnimation
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // 进度圆环
            CircularProgressView(
                progress: progress,
                color: color,
                size: 100,
                showCompletionAnimation: showCompletionAnimation
            )
            
            // 状态文本
            Text(statusText)
                .font(.headline)
                .foregroundColor(.secondary)
                .animation(.easeInOut, value: statusText)
            
            // 进度百分比
            Text("\(Int(progress * 100))%")
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(color)
                .animation(.easeInOut, value: progress)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
