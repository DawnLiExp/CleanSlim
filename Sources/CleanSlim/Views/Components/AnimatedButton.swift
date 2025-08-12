//
//  AnimatedButton.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import SwiftUI

/// 动画按钮组件，提供动态效果的按钮
public struct AnimatedButton: View {
    /// 按钮标题
    let title: String
    
    /// 按钮图标名称
    let iconName: String
    
    /// 按钮颜色
    let color: Color
    
    /// 按钮点击动作
    let action: () -> Void
    
    /// 是否显示加载动画
    var isLoading: Bool = false
    
    /// 动画速度（秒）- 可调整参数
    var animationDuration: Double = 0.6
    
    /// 按钮状态
    @State private var isPressed = false

    /// 鼠标悬浮状态
    @State private var isHovered = false

    /// 旋转角度
    @State private var rotationDegree: Double = 0
    
    public init(title: String, iconName: String, color: Color, action: @escaping () -> Void, isLoading: Bool = false, animationDuration: Double = 0.6) {
        self.title = title
        self.iconName = iconName
        self.color = color
        self.action = action
        self.isLoading = isLoading
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // 延迟恢复按钮状态，产生弹性效果
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            HStack {
                if isLoading {
                    // 加载中显示旋转动画
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                        .rotationEffect(.degrees(rotationDegree))
                } else {
                    // 正常状态显示图标
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isHovered ? color : color.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(9)
            .shadow(color: color.opacity(isHovered ? 0.6 : 0.4), radius: isHovered ? 8 : 5, x: 0, y: isHovered ? 4 : 3)
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        // 监听isLoading变化，重新触发动画
        .onChange(of: isLoading) { newValue in
            if newValue {
                // 重置旋转角度并重新触发动画
                rotationDegree = 0
                withAnimation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                    rotationDegree = 360
                }
            }
        }
        // 初始加载时触发动画
        .onAppear {
            if isLoading {
                withAnimation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                    rotationDegree = 360
                }
            }
        }
    }
}
