//
//  CategoryCard.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import AppKit
import SwiftUI

/// 分类卡片组件，显示缓存分类信息
public struct CategoryCard: View {
    /// 缓存分类
    let category: CacheCategory
    
    /// 切换选中状态的回调
    let onToggle: () -> Void
    
    public init(category: CacheCategory, onToggle: @escaping () -> Void) {
        self.category = category
        self.onToggle = onToggle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和选择框
            HStack {
                // 分类图标
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(.blue) // 使用固定颜色替代category.color
                
                // 分类名称
                Text(LocalizationHelper.string(category.name))
                    .font(.headline)
                
                Spacer()
                
                // 选择框
                Image(systemName: category.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            
            // 分隔线
            Divider()
            
            // 文件数量
            // 文件数量和缓存大小在同一行
            HStack {
                // 文件数量（靠左）
                HStack(spacing: 4) {
                    Text("\(category.fileCount)")
                        .font(.title3)
                        .fontWeight(.bold)
        
                    Text(LocalizationHelper.string("files"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
    
                Spacer()
    
                // 缓存大小（靠右）
                Text(ByteCountFormatter.string(fromBytes: category.size))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        // 添加内边距
        .padding()
        // 设置背景
        .background(
            // 使用线性渐变作为背景
            LinearGradient(
                // 定义渐变颜色（从半透明的控件背景色到更透明的版本）
                gradient: Gradient(colors: [
                    Color(.controlBackgroundColor).opacity(0.95), // 顶部稍深
                    Color(.controlBackgroundColor).opacity(0.8) // 底部稍浅
                ]),
                // 渐变方向：从上到下
                startPoint: .top,
                endPoint: .bottom
            )
    
            // 在背景上叠加一个圆角边框
            .overlay(
                // 圆角矩形边框
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        // 边框使用另一个线性渐变
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary.opacity(0.3), // 左上角稍明显
                                Color.primary.opacity(0.03) // 右下角更淡
                            ]),
                            // 渐变方向：从左上到右下
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1 // 边框宽度为1点
                    )
            )
        )

        // 设置整个视图的圆角（12点）
        .cornerRadius(12)
        // 添加阴影效果
        .shadow(
            color: Color.black.opacity(0.1), // 半透明黑色阴影
            radius: 5, // 阴影模糊半径
            x: 0, // 水平偏移
            y: 2 // 垂直向下偏移2点
        )

        // 添加点击手势
        .onTapGesture {
            onToggle() // 点击时执行传入的切换函数
        }
        // 添加右键菜单（放在修饰符链末尾）
        .contextMenu {
            Button {
                NSWorkspace.shared.open(category.path)
            } label: {
                Label(LocalizationHelper.string("show.in.finder"), systemImage: "folder")
            }
        }
    }
}
