//
//  FlowLayout.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/24/25.
//
import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var width: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if rowWidth + viewSize.width > maxWidth {
                width = max(width, rowWidth - spacing)
                height += rowHeight + spacing
                rowWidth = viewSize.width + spacing
                rowHeight = viewSize.height
            } else {
                rowWidth += viewSize.width + spacing
                rowHeight = max(rowHeight, viewSize.height)
            }
        }
        
        width = max(width, rowWidth - spacing)
        height += rowHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let maxWidth = bounds.width
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var rowStartIndex = 0
        
        var x = bounds.minX
        var y = bounds.minY
        
        for index in subviews.indices {
            let viewSize = subviews[index].sizeThatFits(.unspecified)
            
            if rowWidth + viewSize.width > maxWidth {
                placeRow(subviews: subviews, from: rowStartIndex, to: index - 1, y: y, height: rowHeight, bounds: bounds)
                
                y += rowHeight + spacing
                rowWidth = viewSize.width + spacing
                rowHeight = viewSize.height
                rowStartIndex = index
            } else {
                rowWidth += viewSize.width + spacing
                rowHeight = max(rowHeight, viewSize.height)
            }
        }
        
        placeRow(subviews: subviews, from: rowStartIndex, to: subviews.indices.last!, y: y, height: rowHeight, bounds: bounds)
    }
    
    private func placeRow(subviews: Subviews, from startIndex: Int, to endIndex: Int, y: CGFloat, height: CGFloat, bounds: CGRect) {
        var x = bounds.minX
        
        for index in startIndex...endIndex {
            let viewSize = subviews[index].sizeThatFits(.unspecified)
            
            subviews[index].place(
                at: CGPoint(x: x, y: y + (height - viewSize.height) / 2),
                proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height)
            )
            
            x += viewSize.width + spacing
        }
    }
}
