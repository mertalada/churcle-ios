import SwiftUI

struct MatchScreen: View {
    @Binding var matches: Set<User>
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Segmented Control
                    HStack(spacing: 0) {
                        TabButton(title: "\(matches.count) Beğeni", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "En Seçkin Profiller", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    if selectedTab == 0 {
                        if matches.isEmpty {
                            // Empty state
                            VStack(spacing: 20) {
                                Image(systemName: "heart.circle")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                                
                                Text("Henüz beğendiğin profil yok")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Profilleri beğen ve eşleşmelerini gör")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // Display matched profiles
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(Array(matches), id: \.id) { user in
                                        LikedProfileCard(user: user)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            }
                        }
                    } else {
                        // Display all available profiles
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(User.sampleUsers) { user in
                                    TopProfileCard(user: user)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.top, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationTitleView(settingsType: .none, isCenter: true)
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color(red: 33 / 255, green: 208 / 255, blue: 3 / 255) : Color.gray.opacity(0.5))
                .cornerRadius(8)
        }
    }
}

struct LikedProfileCard: View {
    let user: User
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(user.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 170, height: 250)
                .clipped()
                .cornerRadius(18)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(user.name), \(user.age)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(user.bio)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedCorner(radius: 18, corners: [.bottomLeft, .bottomRight]))
            )
        }
        .frame(width: 170, height: 250)
        .shadow(radius: 6)
    }
}

struct TopProfileCard: View {
    let user: User
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(user.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 170, height: 250)
                .clipped()
                .cornerRadius(18)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(user.name), \(user.age)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(user.bio)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedCorner(radius: 18, corners: [.bottomLeft, .bottomRight]))
            )
        }
        .frame(width: 170, height: 250)
        .shadow(radius: 6)
    }
}

#Preview {
    MatchScreen(matches: .constant(Set<User>()))
} 