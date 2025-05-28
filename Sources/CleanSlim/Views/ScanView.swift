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

    /// 鼠标悬停状态
    @State private var isHovered = false

    public init(viewModel: CacheScannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // 扫描进度环
            ZStack {
                // 背景圆形玻璃效果
                Circle()
                    .fill(Color.clear)
                    .frame(width: 120, height: 120)
                    .background(
                        VisualEffectView(
                            material: .popover,
                            blendingMode: .withinWindow,
                            emphasized: false
                        )
                        .clipShape(Circle())
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                // 进度环
                CircularProgressView(
                    progress: viewModel.scanProgress,
                    color: Color.blue,
                    size: 100
                )
            }
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
        .background(
            // 微妙的背景纹理
            TexturedBackgroundView(
                backgroundColor: Color.clear,
                textureOpacity: 0.02,
                enableTexture: true
            )
        )
    }
}
