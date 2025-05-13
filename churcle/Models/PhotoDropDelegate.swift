import SwiftUI

struct PhotoDropDelegate: DropDelegate {
    let destinationItem: PhotoItem
    @Binding var photoItems: [PhotoItem]
    @Binding var draggingItem: PhotoItem?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem else { return }
        
        if let sourceIndex = photoItems.firstIndex(where: { $0.id == draggingItem.id }),
           let destinationIndex = photoItems.firstIndex(where: { $0.id == destinationItem.id }),
           sourceIndex != destinationIndex {
            withAnimation {
                photoItems.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex)
            }
        }
    }
} 