//
//  CircularProgressView.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//


import SwiftUI

/// 圆形进度视图组件，显示进度环
public struct CircularProgressView: View {
    /// 进度值 (0.0 - 1.0)
    let progress: Double
    
    /// 进度环颜色
    let color: Color
    
    /// 进度环大小
    let size: CGFloat
    
    /// 是否显示完成动画
    var showCompletionAnimation: Bool = true
    
    /// 线宽
    private let lineWidth: CGFloat = 8
    
    /// 完成状态
    @State private var isCompleted = false
    
    /// 动画进度
    @State private var animatedProgress: Double = 0
    
    /// 是否显示勾号
    @State private var showCheckmark = false
    
    public init(progress: Double, color: Color, size: CGFloat, showCompletionAnimation: Bool = true) {
        self.progress = progress
        self.color = color
        self.size = size
        self.showCompletionAnimation = showCompletionAnimation
    }
    
    public var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.2)
                .foregroundColor(color)
            
            // 进度圆环
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.animatedProgress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
            
            // 完成动画
            if showCompletionAnimation && animatedProgress >= 1.0 && !isCompleted {
                Circle()
                    .fill(color.opacity(0.2))
                    .scaleEffect(isCompleted ? 1.3 : 0)
                    .opacity(isCompleted ? 0 : 1)
                    .animation(.easeOut(duration: 0.6), value: isCompleted)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isCompleted = true
                        }
                    }
            }
            
            // 中心图标
            if showCheckmark {
                Image(systemName: "checkmark")
                    .font(.system(size: size / 4, weight: .bold))
                    .foregroundColor(color)
                    .opacity(showCheckmark ? 1 : 0)
                    .scaleEffect(showCheckmark ? 1 : 0.5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheckmark)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            // 重置状态
            self.isCompleted = false
            self.showCheckmark = false
            
            // 添加延迟，确保动画可见
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.easeInOut(duration: 0.8)) { // 完成动画
                    self.animatedProgress = self.progress
                }
                
                // 进度完成后显示勾号
                if self.progress >= 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            self.showCheckmark = true
                        }
                    }
                }
            }
        }
        // 关键修复：监听progress变化并更新animatedProgress
        .onChange(of: progress) { newProgress in
            withAnimation(.easeInOut(duration: 0.3)) { // 清理动画
                self.animatedProgress = newProgress
            }
            
            // 进度完成后显示勾号
            if newProgress >= 1.0 && !showCheckmark {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        self.showCheckmark = true
                    }
                }
            }
        }
    }
}
