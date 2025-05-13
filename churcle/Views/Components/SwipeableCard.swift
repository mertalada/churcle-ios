import SwiftUI

struct SwipeableCard: View {
    let user: User
    var onRemove: ((Bool) -> Void)?
    var swipeState: SwipeState
    @State private var showProfileSheet = false
    @State private var currentPhotoIndex = 0
    
    // HomeScreen'deki buton işlevleri için callback'ler
    var onRewind: (() -> Void)? = nil
    var onSwipeLeft: (() -> Void)? = nil
    var onSuperLike: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil
    var onMessage: (() -> Void)? = nil
    
    // Fotoğraf karuselinde kullanılacak test verileri (şimdilik aynı fotoğraf)
    let photos = [0, 1, 2] // Örnek fotoğraf indeksleri
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Fotoğraf Karuseli
                ZStack(alignment: .top) {
                    // TabView yerine sadece mevcut fotoğrafı gösteriyoruz
                    Image(user.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        // İndekse göre farklı efektler eklenebilir
                        .brightness(currentPhotoIndex == 0 ? 0 : currentPhotoIndex == 1 ? 0.1 : -0.1)
                        .overlay(
                            ZStack {
                                // Sola geçiş butonu (görünmez)
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
                                    // Sağa geçiş butonu (görünmez)
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
                                
                                // LIKE/NOPE/SUPERLIKE overlay'leri
                                if swipeState == .like {
                                    Circle()
                                        .fill(Color.green.opacity(0.4))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.green)
                                        )
                                }
                                
                                if swipeState == .nope {
                                    Circle()
                                        .fill(Color.red.opacity(0.4))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "xmark")
                                                .font(.system(size: 50))
                                                .foregroundColor(.red)
                                        )
                                }
                                
                                if swipeState == .superLike {
                                    Circle()
                                        .fill(Color.blue.opacity(0.4))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.blue)
                                        )
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
                }
                
                // User Info Overlay
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(user.name), \(user.age)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                        Spacer()
                        Button(action: { showProfileSheet = true }) {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            .sheet(isPresented: $showProfileSheet) {
                ProfileDetailSheetView(
                    user: user,
                    isPresented: $showProfileSheet,
                    onRewind: onRewind,
                    onSwipeLeft: onSwipeLeft,
                    onSuperLike: onSuperLike,
                    onSwipeRight: onSwipeRight,
                    onMessage: onMessage
                )
                .presentationDetents([.fraction(0.9)])
                .presentationCornerRadius(30)
                .presentationBackground(Color.black)
            }
        }
    }
}

enum SwipeState {
    case none, like, nope, superLike
}

#Preview {
    SwipeableCard(user: User.sampleUsers[0], swipeState: .none)
        .frame(height: 600)
} 