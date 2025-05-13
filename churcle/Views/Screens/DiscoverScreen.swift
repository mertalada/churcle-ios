import SwiftUI

struct DiscoverCategory: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let count: Int
    let iconName: String
    let backgroundColor: Color
}

struct CategorySection: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let categories: [DiscoverCategory]
}

struct DiscoverScreen: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sections: [CategorySection] = [
        CategorySection(
            title: "Discover",
            description: "Find others who share your passions.",
            categories: [
                DiscoverCategory(
                    title: "Artists",
                    subtitle: nil,
                    count: 85,
                    iconName: "paintbrush.fill",
                    backgroundColor: .blue
                ),
                DiscoverCategory(
                    title: "Foodies",
                    subtitle: nil,
                    count: 77,
                    iconName: "fork.knife",
                    backgroundColor: .pink
                ),
                DiscoverCategory(
                    title: "Nature",
                    subtitle: "Lovers",
                    count: 85,
                    iconName: "leaf.fill",
                    backgroundColor: .teal
                ),
                DiscoverCategory(
                    title: "Music",
                    subtitle: "Enthusiasts",
                    count: 77,
                    iconName: "music.note",
                    backgroundColor: .purple
                )
            ]
        ),
        CategorySection(
            title: "Common Goals",
            description: "Connect with people who share your aspirations",
            categories: [
                DiscoverCategory(
                    title: "Family Oriented",
                    subtitle: "Find people with similar family values",
                    count: 22,
                    iconName: "heart.circle.fill",
                    backgroundColor: .purple
                )
            ]
        ),
        CategorySection(
            title: "Passions",
            description: "Meet people who share your interests",
            categories: [
                DiscoverCategory(
                    title: "Outdoor",
                    subtitle: "Activities",
                    count: 129,
                    iconName: "figure.hiking",
                    backgroundColor: .orange
                ),
                DiscoverCategory(
                    title: "Gaming",
                    subtitle: "Enthusiasts",
                    count: 81,
                    iconName: "gamecontroller.fill",
                    backgroundColor: .purple
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(sections) { section in
                            if !section.title.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(section.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(section.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                            
                            if section.categories.count == 1 {
                                // Full width card
                                FullWidthCard(category: section.categories[0])
                                    .padding(.horizontal)
                            } else {
                                // Grid of cards
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(section.categories) { category in
                                        CategoryCard(category: category)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
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

struct CategoryCard: View {
    let category: DiscoverCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content
            ZStack {
                Rectangle()
                    .fill(category.backgroundColor)
                    .aspectRatio(1, contentMode: .fit)
                
                // User count badge
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 60, height: 30)
                            
                            HStack(spacing: 4) {
                                Text("\(category.count)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12))
                            }
                        }
                        .padding(8)
                    }
                    
                    Spacer()
                }
                
                // Icon
                VStack(spacing: 0) {
                    Spacer()
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                    
                    Text(category.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if let subtitle = category.subtitle {
                        Text(subtitle)
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .cornerRadius(12)
        }
    }
}

struct FullWidthCard: View {
    let category: DiscoverCategory
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(category.backgroundColor)
                .frame(height: 180)
                .cornerRadius(12)
            
            // User count badge
            VStack {
                HStack {
                    Spacer()
                    
                    ZStack {
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 60, height: 30)
                        
                        HStack(spacing: 4) {
                            Text("\(category.count)")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        }
                    }
                    .padding(16)
                }
                
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: category.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    Spacer()
                }
                
                Text(category.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let subtitle = category.subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(20)
        }
    }
}

#Preview {
    DiscoverScreen()
} 
