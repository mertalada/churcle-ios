import SwiftUI

// Photo cell for displaying photos
struct PhotoCell: View {
    let image: UIImage
    
    var body: some View {
        ZStack {
            Color.black // Background for empty spaces
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .frame(minWidth: 0, maxWidth: .infinity)
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// Placeholder cell for adding new photos
struct PhotoPlaceholderCell: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundColor(.gray)
                .frame(height: 150)
            
            Image(systemName: "plus")
                .font(.system(size: 30))
                .foregroundColor(.red)
        }
    }
} 