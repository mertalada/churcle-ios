import SwiftUI

struct ProfileDetailSheetView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let user: User
    @Binding var isPresented: Bool
    @State private var currentPhotoIndex = 0
    
    // Dummy photos array for now - this would come from user model in a complete implementation
    let photos = [0, 1, 2] // Example photo indexes
    
    // Callback functions for buttons
    var onRewind: (() -> Void)? = nil
    var onSwipeLeft: (() -> Void)? = nil
    var onSuperLike: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil
    var onMessage: (() -> Void)? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.6))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                
        ZStack(alignment: .top) {
            // background for entire view
            Color.sheetBackground
                .edgesIgnoringSafeArea(.all)
            
            // Main content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo carousel
                    ZStack(alignment: .top) {
                        TabView(selection: $currentPhotoIndex) {
                            ForEach(photos, id: \.self) { index in
                                Image(user.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 550)
                                    .background(Color.sheetBackground)
                                    .clipped()
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 530)
                        
                        // Photo indicator lines
                        HStack(spacing: 4) {
                            ForEach(photos, id: \.self) { index in
                                Rectangle()
                                    .fill(currentPhotoIndex == index ? Color.white : Color.gray.opacity(0.6))
                                    .frame(height: 3)
                                    .frame(width: UIScreen.main.bounds.width / CGFloat(photos.count) - 8)
                                    .cornerRadius(1.5)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 12)
                    }
                    
                    // This creates space for the content card to overlap
                    Spacer()
                        .frame(height: 40)
                }
                
                // Red content card - moved outside the VStack to control position
                VStack(alignment: .leading, spacing: 18) {
                    // Header section with name and distance
                    HStack(alignment: .center) {
                        Text("\(user.name), \(user.age)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(user.distance) km")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    
                    // Workplace
                    Text("Model")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)

                    // About
                    Text("About")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    Text(user.bio)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)    

                      // Looking for section
                    Text("Looking for")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("friends")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .cornerRadius(16)
                        Spacer()
                    }
                        
                    // Education (placeholder - would come from user model)
                    Text("Education")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("İstanbul Üniversitesi")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    // Horoscope (placeholder - would come from user model)
                    Text("Horoscope")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text("Koç")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        // Horoscope emoji
                        Text("♈️")
                            .font(.system(size: 18))
                    }
                    
                    // Interests
                    Text("Interest")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Custom interest layout
                    CustomInterestLayout(items: ["Gym & Fitness", "Food & Drink", "Travel", "Art", "Design"])
                    
                    // City and distance info
                    VStack {
                        Text("İstanbul")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("\(user.distance) km uzakta")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    
                    // Action buttons in a row
                    HStack(spacing: 10) {
                        Spacer()
                        
                        Button(action: {
                            onRewind?()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 30))
                                .foregroundColor(.yellow)
                        }
                        
                        Button(action: {
                            onSwipeLeft?()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                        }
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        
                        Button(action: {
                            onSuperLike?()
                        }) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            onSwipeRight?()
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                        }
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        
                        Button(action: {
                            onMessage?()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.purple)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 15)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .background(Color.sheetBackground)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .offset(y: -70) // Pull the card up to overlap with photo
                .padding(.bottom, -70) // Adjust scroll view content size
            }
            .edgesIgnoringSafeArea(.top)
        }
        .background(Color.sheetBackground)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}

// Custom layout for interests that adapts to content width
struct CustomInterestLayout: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            FlowLayout(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    interestButton(title: item)
                }
            }
        }
    }
    
    private func interestButton(title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 15))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.blue)
        .cornerRadius(18)
    }
}

// Belirli köşeleri yuvarlatmak için helper shape
struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ProfileDetailSheetView(user: User.sampleUsers[0], isPresented: .constant(true))
        .background(Color.black)
        .frame(height: 700)
} 
