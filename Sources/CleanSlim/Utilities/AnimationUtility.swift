//
//  AnimationUtility.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//


import SwiftUI

/// 动画工具类，提供常用动画效果
public struct AnimationUtility {
    /// 弹性动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - dampingFraction: 阻尼系数，值越小弹性越大
    /// - Returns: 动画效果
    public static func springAnimation(duration: Double = 0.3, dampingFraction: Double = 0.6) -> Animation {
        return Animation.spring(response: duration, dampingFraction: dampingFraction)
    }
    
    /// 缓入缓出动画
    /// - Parameter duration: 动画持续时间
    /// - Returns: 动画效果
    public static func easeInOutAnimation(duration: Double = 0.3) -> Animation {
        return Animation.easeInOut(duration: duration)
    }
    
    /// 循环动画
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - autoreverses: 是否自动反转
    /// - Returns: 动画效果
    public static func repeatForeverAnimation(duration: Double = 1.0, autoreverses: Bool = false) -> Animation {
        return Animation.linear(duration: duration).repeatForever(autoreverses: autoreverses)
    }
}
