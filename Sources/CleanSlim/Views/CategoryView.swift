//
//  CategoryView.swift
//  CleanSlim
//
//  Created by Me2 on 2025/5/18.
//

import SwiftUI

/// 分类视图，显示缓存分类列表
public struct CategoryView: View {
    /// 缓存扫描视图模型
    @ObservedObject var viewModel: CacheScannerViewModel
    
    public init(viewModel: CacheScannerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 22) {
            // 全选按钮
            HStack {
                Spacer() // 将内容推到右侧
    
                Button(action: {
                    viewModel.toggleAllSelection()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isAllSelected ? "checkmark.square.fill" : "square")
                            .font(.title) // 调整选择框大小
                            .foregroundColor(.blue)
            
                        Text(LocalizationHelper.string("select.all"))
                            .font(.title3) // 调整文字大小
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            // 分类列表
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.categories) { category in
                    CategoryCard(
                        category: category,
                        onToggle: {
                            viewModel.toggleCategorySelection(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 清理按钮
            if viewModel.scanState == .scanned && viewModel.totalCacheSize > 0 {
                AnimatedButton(
                    title: LocalizationHelper.string("clean"),
                    iconName: "sparkles",
                    color: Color.green,
                    action: {
                        viewModel.cleanSelectedCaches()
                    },
                    isLoading: viewModel.scanState == .cleaning
                )
                .padding(.top, 8)
            }
        }
    }
}
