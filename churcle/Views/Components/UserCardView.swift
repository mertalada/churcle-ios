import SwiftUI

struct UserCardView: View {
    let user: User
    @State private var currentPhotoIndex = 0
    
    // Fotoğraf karuselinde kullanılacak test verileri (şimdilik aynı fotoğraf)
    let photos = [0, 1, 2] // Örnek fotoğraf indeksleri
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .top) {
                    // Fotoğraf Karuseli - TabView kaldırıldı
                    Image(user.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .brightness(currentPhotoIndex == 0 ? 0 : currentPhotoIndex == 1 ? 0.1 : -0.1)
                        .overlay(
                            ZStack {
                                // Sola geçiş butonu
                                HStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation {
                                                currentPhotoIndex = max(0, currentPhotoIndex - 1)
                                            }
                                        }
                                    Spacer()
                                    // Sağa geçiş butonu
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: geometry.size.width / 3, height: geometry.size.height)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation {
                                                currentPhotoIndex = min(photos.count - 1, currentPhotoIndex + 1)
                                            }
                                        }
                                }
                            }
                        )
                    
                    // Fotoğraf Göstergeleri
                    HStack(spacing: 4) {
                        ForEach(photos, id: \.self) { index in
                            Rectangle()
                                .fill(currentPhotoIndex == index ? Color.white : Color.gray.opacity(0.6))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                    
                    // User Info Overlay
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(user.name), \(user.age)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                            Text("\(user.distance) km uzakta")
                                .foregroundColor(.white)
                        }
                        
                        Text(user.bio)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    UserCardView(user: User.sampleUsers[0])
        .frame(height: 500)
} 