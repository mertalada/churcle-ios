import SwiftUI

// Custom FlowLayout to allow tags to flow to next line
struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        let rows = getRows(containerWidth: containerWidth, subviews: subviews)
        
        for row in rows {
            height += row.maxY
            if row != rows.last {
                height += spacing
            }
        }
        
        return CGSize(width: containerWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let containerWidth = bounds.width
        let rows = getRows(containerWidth: containerWidth, subviews: subviews)
        
        var y = bounds.minY
        for row in rows {
            for item in row.items {
                let x = item.x + bounds.minX
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: item.width, height: item.height)
                )
            }
            y += row.maxY + spacing
        }
    }
    
    private func getRows(containerWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > containerWidth && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                x = 0
            }
            
            let item = Item(index: index, size: size, x: x)
            currentRow.items.append(item)
            x += size.width + spacing
        }
        
        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    struct Item: Equatable {
        var index: Int
        var size: CGSize
        var x: CGFloat
        
        var width: CGFloat { size.width }
        var height: CGFloat { size.height }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.index == rhs.index
        }
    }
    
    struct Row: Equatable {
        var items: [Item] = []
        
        var maxY: CGFloat {
            items.map { $0.height }.max() ?? 0
        }
        
        static func == (lhs: Row, rhs: Row) -> Bool {
            guard lhs.items.count == rhs.items.count else { return false }
            for i in 0..<lhs.items.count {
                if lhs.items[i] != rhs.items[i] {
                    return false
                }
            }
            return true
        }
    }
} 