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
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture {
            onToggle()
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
