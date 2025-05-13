import SwiftUI

struct PhotoItem: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
 
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
    }
} 