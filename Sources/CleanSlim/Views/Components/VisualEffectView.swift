//
//  VisualEffectView.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/27.
//

import SwiftUI
import AppKit

/// 磨砂玻璃效果视图，提供半透明模糊背景
/// 使用NSVisualEffectView实现原生macOS磨砂玻璃效果
public struct VisualEffectView: NSViewRepresentable {
    /// 模糊效果类型
    let material: NSVisualEffectView.Material

    /// 模糊效果状态
    let blendingMode: NSVisualEffectView.BlendingMode

    /// 是否强调
    let isEmphasized: Bool

    /// 初始化视图
    /// - Parameters:
    ///   - material: 材质类型，默认为popover（轻微磨砂效果）
    ///   - blendingMode: 混合模式，默认为behindWindow（在窗口后混合）
    ///   - emphasized: 是否强调，默认为false
    public init(
        material: NSVisualEffectView.Material = .popover,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = false
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.isEmphasized = emphasized
    }

    /// 创建NSView
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.isEmphasized = isEmphasized
        view.state = .active
        return view
    }

    /// 更新NSView
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = isEmphasized
    }
}

/// 微纹理背景视图，提供细微噪点纹理
/// 使用高效的图案重复方式实现，避免性能问题
public struct TexturedBackgroundView: View {
    /// 背景颜色
    let backgroundColor: Color

    /// 纹理不透明度
    let textureOpacity: Double

    /// 是否启用纹理（可用于调试或性能优化）
    let enableTexture: Bool

    /// 初始化视图
    /// - Parameters:
    ///   - backgroundColor: 背景基础颜色，默认为窗口背景色
    ///   - textureOpacity: 纹理不透明度，控制纹理强度，默认0.03（非常微妙）
    ///   - enableTexture: 是否启用纹理，可设为false以完全禁用纹理效果
    public init(
        backgroundColor: Color = Color(.windowBackgroundColor),
        textureOpacity: Double = 0.03,
        enableTexture: Bool = true
    ) {
        self.backgroundColor = backgroundColor
        self.textureOpacity = textureOpacity
        self.enableTexture = enableTexture
    }

    public var body: some View {
        ZStack {
            // 基础背景色
            backgroundColor

            // 纹理层 - 仅在启用时显示
            if enableTexture {
                // 使用预定义的点阵图案，比随机生成更高效
                NoisePatternView(opacity: textureOpacity)
                    .blendMode(.overlay) // 叠加混合模式，使纹理与背景融合
            }
        }
    }
}

/// 噪点图案视图 - 使用高效的重复图案实现微纹理
/// 避免使用大量随机Circle或Canvas.noise，提高性能
private struct NoisePatternView: View {
    /// 纹理不透明度
    let opacity: Double

    /// 图案尺寸
    let patternSize: CGFloat = 200

    /// 点的数量（每个维度）
    let dotsPerDimension: Int = 20

    var body: some View {
        // 使用GeometryReader获取可用空间
        GeometryReader { geometry in
            // 创建一个可重复使用的基本图案
            let pattern = createNoisePattern()
                .frame(width: patternSize, height: patternSize)
                .opacity(opacity)

            // 计算需要多少个图案来填充整个区域
            let columns = Int(ceil(geometry.size.width / patternSize))
            let rows = Int(ceil(geometry.size.height / patternSize))

            // 使用ZStack叠加所有图案
            ZStack {
                // 使用固定位置的图案填充整个区域
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { column in
                        pattern
                            .position(
                                x: CGFloat(column) * patternSize + patternSize/2,
                                y: CGFloat(row) * patternSize + patternSize/2
                            )
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    /// 创建基本噪点图案 - 使用固定位置的点阵而非随机点
    /// 这种方法比随机生成点更高效，且视觉效果相似
    private func createNoisePattern() -> some View {
        let dotSize: CGFloat = 1
        let spacing = patternSize / CGFloat(dotsPerDimension)

        return ZStack {
            // 创建固定位置的点阵，但使用随机不透明度
            ForEach(0..<dotsPerDimension, id: \.self) { row in
                ForEach(0..<dotsPerDimension, id: \.self) { column in
                    // 使用固定种子的伪随机值，确保每次渲染相同
                    let randomValue = Double((row * 31 + column * 17) % 100) / 100.0

                    // 只有部分点可见，创造随机感
                    if randomValue > 0.7 {
                        Circle()
                            .fill(Color.white)
                            .frame(width: dotSize, height: dotSize)
                            .position(
                                x: CGFloat(column) * spacing + spacing/2,
                                y: CGFloat(row) * spacing + spacing/2
                            )
                            .opacity(randomValue)
                    }
                }
            }
        }
    }
}

/// 玻璃卡片背景，提供磨砂玻璃效果和微妙阴影
/// 用于分类卡片等需要突出显示的UI元素
public struct GlassCardBackground: View {
    /// 是否悬停
    let isHovered: Bool

    /// 是否选中
    let isSelected: Bool

    /// 背景颜色
    let backgroundColor: Color

    /// 初始化视图
    /// - Parameters:
    ///   - isHovered: 鼠标是否悬停在卡片上
    ///   - isSelected: 卡片是否被选中
    ///   - backgroundColor: 卡片背景基础颜色
    public init(
        isHovered: Bool = false,
        isSelected: Bool = false,
        backgroundColor: Color = Color(.controlBackgroundColor)
    ) {
        self.isHovered = isHovered
        self.isSelected = isSelected
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        ZStack {
            // 磨砂玻璃背景 - 提供基础模糊效果
            VisualEffectView(
                material: .popover,
                blendingMode: .withinWindow,
                emphasized: isHovered
            )

            // 微妙的渐变叠加 - 增加深度感和立体感
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor.opacity(isHovered ? 0.3 : 0.5),
                    backgroundColor.opacity(isHovered ? 0.2 : 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 选中状态边框 - 仅在选中时显示
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            }
        }
        .cornerRadius(12)
        .shadow(
            color: Color.black.opacity(isHovered ? 0.15 : 0.1),
            radius: isHovered ? 8 : 5,
            x: 0,
            y: isHovered ? 4 : 2
        )
    }
}
