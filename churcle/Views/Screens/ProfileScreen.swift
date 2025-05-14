import SwiftUI

struct ProfileScreen: View {
    @State private var showEditSheet: Bool = false
    @State private var showDetailSheet: Bool = false
    @StateObject private var userProfile = UserProfile.shared
    @Binding var matches: Set<User>
    @State private var currentPhotoIndex = 0
    @State private var selectedPlan: PlanType = .gold // Default selected plan
    @EnvironmentObject private var themeManager: ThemeManager
    
    enum PlanType: String, CaseIterable {
        case basic = "Basic"
        case gold = "Gold"
        case platinum = "Platinum"
        
        var price: String {
            switch self {
            case .basic: return "₺15.99"
            case .gold: return "₺25.99"
            case .platinum: return "₺35.99"
            }
        }
        
        var features: [String] {
            switch self {
            case .basic: 
                return ["Günlük 25 Beğeni", "1 Süper Beğeni / Gün", "Sınırlı Keşif"]
            case .gold: 
                return ["Sınırsız Beğeni", "5 Süper Beğeni / Gün", "Ay 1 Boost", "Geri Alma Hakkı", "Gezdiğin Tüm Profilleri Görme"]
            case .platinum: 
                return ["Gold'un Tüm Özellikleri", "10 Süper Beğeni / Gün", "Aylık 3 Boost", "Öncelikli Keşif", "Direkt Mesaj Gönderme", "Profil Vurgulama"]
            }
        }
        
        var colors: (main: Color, accent: Color) {
            switch self {
            case .basic:
                return (Color(red: 0.75, green: 0.75, blue: 0.77), Color(red: 0.65, green: 0.65, blue: 0.68))
            case .gold:
                return (Color(red: 0.98, green: 0.82, blue: 0.25), Color(red: 0.92, green: 0.75, blue: 0.2))
            case .platinum:
                return (Color(red: 0.15, green: 0.25, blue: 0.45), Color(red: 0.25, green: 0.35, blue: 0.55))
            }
        }
        
        var badge: String? {
            switch self {
            case .gold: return "EN POPÜLER"
            case .platinum: return "EN İYİ DEĞER"
            case .basic: return nil
            }
        }
    }
    
    var body: some View {
        NavigationView {
            // Use GeometryReader to ensure proper scrolling
            GeometryReader { geometry in
                ScrollView(showsIndicators: true) {
                VStack(spacing: 20) {
                        // Profile Card
                        ZStack(alignment: .bottom) {
                            // Photo Carousel
                            ZStack(alignment: .top) {
                                // Current photo
                                if !userProfile.photos.isEmpty {
                                    Image(uiImage: userProfile.photos[safe: currentPhotoIndex]?.image ?? UIImage(named: "profile")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 550)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(
                                            ZStack {
                                                // Left/right tap areas for photo navigation
                                                HStack {
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(height: 550)
                                                        .contentShape(Rectangle())
                                                        .onTapGesture {
                                                            withAnimation {
                                                                currentPhotoIndex = max(0, currentPhotoIndex - 1)
                                                            }
                                                        }
                                                    Spacer()
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(height: 550)
                                                        .contentShape(Rectangle())
                                                        .onTapGesture {
                                                            withAnimation {
                                                                currentPhotoIndex = min(userProfile.photos.count - 1, currentPhotoIndex + 1)
                                                            }
                                                        }
                                                }
                                            }
                                        )
                                } else {
                        Image("profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                                        .frame(height: 550)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                
                                // Photo indicators
                                HStack(spacing: 4) {
                                    ForEach(0..<userProfile.photos.count, id: \.self) { index in
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
                                    Text("\(userProfile.name), \(userProfile.age)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                    Spacer()
                                    
                                    Button(action: {
                                        showDetailSheet = true
                                    }) {
                                        Image(systemName: "chevron.down.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                }
                                }
                                
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.white)
                                    Text("\(userProfile.distance) km uzakta")
                                        .foregroundColor(.white)
                                }
                                
                                Text(userProfile.bio)
                                    .foregroundColor(.white)
                                    .font(.body)
                                    .padding(.bottom, 8)
                                
                                // Edit Profile Button
                                Button(action: {
                                    showEditSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Profili Düzenle")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                            .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white, lineWidth: 1)
                            )
                                }
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
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        // Statistics section
                        VStack(spacing: 15) {
                            Text("Profil İstatistikleri")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            HStack(spacing: 25) {
                                // Use the parent's likes and matches count
                                StatView(value: "\(MainTabView.likes)", label: "Beğeni")
                                StatView(value: "\(matches.count)", label: "Eşleşme")
                                StatView(value: "\(userProfile.calculateProfileCompletion())%", label: "Tamamlanma")
                    }
                    .padding()
                            .background(themeManager.isDarkMode ? Color.black : Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        
                        // Subscription Plans Section - Spotify Inspired Design
                        VStack(spacing: 24) {
                            Text("Churcle Planları")
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            // Plan selection tabs at the top
                            HStack(spacing: 0) {
                                ForEach(PlanType.allCases, id: \.self) { plan in
                                    Button(action: {
                                        withAnimation {
                                            selectedPlan = plan
                                        }
                                    }) {
                                        Text(plan.rawValue)
                                            .font(.system(size: 15, weight: .semibold))
                                            .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                            .background(backgroundForPlan(plan))
                                            .foregroundColor(selectedPlan == plan ? .white : .gray)
                                    }
                                    .cornerRadius(8)
                                }
                            }
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        .padding(.horizontal)
                            
                            // Featured Plan - Based on selection
                            VStack(spacing: 0) {
                                // Price banner
                                HStack {
                                    Text(selectedPlan.price)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("/ AY")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                    
                                    // Badge if applicable
                                    if let badge = selectedPlan.badge {
                                        Text(badge)
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.white)
                                            .foregroundColor(selectedPlan.colors.main)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            selectedPlan.colors.main,
                                            selectedPlan.colors.accent
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                
                                // Features list
                                VStack(spacing: 0) {
                                    // Features
                                    VStack(spacing: 0) {
                                        ForEach(selectedPlan.features, id: \.self) { feature in
                                            FeatureRow(text: feature, isIncluded: true)
                                        }
                                    }
                                    .padding(.vertical, 16)
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 20)
                                    
                                    // Call to action button
                                    Button(action: {
                                        // Subscribe action
                                    }) {
                                        HStack {
                                            Text("SATIN AL")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(selectedPlan.colors.main)
                                        .cornerRadius(30)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 16)
                                        .padding(.bottom, 20)
                                    }
                                }
                                .background(themeManager.isDarkMode ? Color.black : Color.white)
                            }
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                            .padding(.horizontal)
                        
                            // Plan comparison section
                            VStack(spacing: 24) {
                                Text("Plan Karşılaştırması")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Comparison rows
                                ComparisonRow(feature: "Günlük Beğeni", basic: "25", gold: "Sınırsız", platinum: "Sınırsız")
                                ComparisonRow(feature: "Süper Beğeni", basic: "1/gün", gold: "5/gün", platinum: "10/gün")
                                ComparisonRow(feature: "Boost", basic: "-", gold: "1/ay", platinum: "3/ay")
                                ComparisonRow(feature: "Geri Alma", basic: "-", gold: "✓", platinum: "✓")
                                ComparisonRow(feature: "Direkt Mesaj", basic: "-", gold: "-", platinum: "✓")
                                
                                // Show all features button
                                Button(action: {
                                    // Show all features action
                                }) {
                                    Text("Tüm Özellikleri Gör")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.blue)
                                        .padding(.vertical, 12)
                                }
                            }
                            .padding()
                            .background(themeManager.isDarkMode ? Color.black : Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.vertical)
                    .frame(minHeight: geometry.size.height)
                }
                .simultaneousGesture(
                    // Empty drag gesture with high priority to ensure scrolling works
                    DragGesture().onChanged { _ in }.onEnded { _ in }
                        .simultaneously(with: planSwitchingGesture())
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationTitleView(settingsType: .profile)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                ProfileEditSheetView()
                    .presentationDetents([.fraction(0.95)])
                    .presentationCornerRadius(30)
                    .presentationBackground(Color.sheetBackground)
            }
            .sheet(isPresented: $showDetailSheet) {
                ProfileInfoSheetView(showEditSheet: $showEditSheet)
                    .presentationDetents([.fraction(0.95)])
                    .presentationCornerRadius(30)
                    .presentationBackground(Color.sheetBackground)
                }
            .onAppear {
                // Make sure current photo index is valid
                if !userProfile.photos.isEmpty {
                    currentPhotoIndex = min(currentPhotoIndex, userProfile.photos.count - 1)
            }
        }
    }
        .background(selectedPlan.colors.main)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: NavigationTitleView(isCenter: true))
        .migrateToThemeManager()
    }
    
    // Extracted the plan switching gesture to a separate function
    private func planSwitchingGesture() -> some Gesture {
        DragGesture()
            .onEnded { value in
                let threshold: CGFloat = 50
                let planIndex = PlanType.allCases.firstIndex(of: selectedPlan) ?? 0
                
                if value.translation.width < -threshold && planIndex < PlanType.allCases.count - 1 {
                    // Swipe left - next plan
                    withAnimation {
                        selectedPlan = PlanType.allCases[planIndex + 1]
                    }
                } else if value.translation.width > threshold && planIndex > 0 {
                    // Swipe right - previous plan
                    withAnimation {
                        selectedPlan = PlanType.allCases[planIndex - 1]
                    }
                }
            }
    }
    
    // Helper function to simplify the background expression
    private func backgroundForPlan(_ plan: PlanType) -> some View {
        Group {
            if selectedPlan == plan {
                plan.colors.main.cornerRadius(8)
            } else {
                Color.clear
            }
        }
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// Feature row for the main plan display
struct FeatureRow: View {
    let text: String
    let isIncluded: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isIncluded ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(isIncluded ? .green : .red.opacity(0.7))
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
}

// Comparison row for the plan comparison table
struct ComparisonRow: View {
    let feature: String
    let basic: String
    let gold: String
    let platinum: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(feature)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            
            HStack(spacing: 0) {
                // Basic
                Text(basic)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.75, green: 0.75, blue: 0.77))
                    .cornerRadius(6, corners: [.topLeft, .bottomLeft])
                
                // Gold
                Text(gold)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.98, green: 0.82, blue: 0.25))
                
                // Platinum
                Text(platinum)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.15, green: 0.25, blue: 0.45))
                    .cornerRadius(6, corners: [.topRight, .bottomRight])
            }
        }
    }
}

#Preview {
    ProfileScreen(matches: .constant(Set<User>()))
} 
