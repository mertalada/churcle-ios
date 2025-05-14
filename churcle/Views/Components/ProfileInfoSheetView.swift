import SwiftUI

struct ProfileInfoSheetView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var userProfile = UserProfile.shared
    @State private var currentPhotoIndex = 0
    @State private var completionPercentage: Int = 0
    @Binding var showEditSheet: Bool
    
    var body: some View {
                
        ZStack(alignment: .top) {
            // Main content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo carousel
                    ZStack(alignment: .top) {
                        TabView(selection: $currentPhotoIndex) {
                            ForEach(0..<userProfile.photos.count, id: \.self) { index in
                                Image(uiImage: userProfile.photos[index].image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 550)
                                    .background(Color.black)
                                    .clipped()
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 530)
                        
                        // Photo indicator lines
                        HStack(spacing: 4) {
                            ForEach(0..<userProfile.photos.count, id: \.self) { index in
                                Rectangle()
                                    .fill(currentPhotoIndex == index ? Color.white : Color.gray.opacity(0.6))
                                    .frame(height: 3)
                                    .frame(width: UIScreen.main.bounds.width / CGFloat(userProfile.photos.count) - 8)
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
                
                // content card - moved outside the VStack to control position
                VStack(alignment: .leading, spacing: 18) {
                    // Header section with name and distance
                    HStack(alignment: .center) {
                        Text("\(userProfile.name), \(userProfile.age)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        Spacer()
                        Text("\(userProfile.distance) km")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    
                    // Workplace
                    if !userProfile.workplace.isEmpty {
                        Text(userProfile.workplace)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                    }

                     // About
                    Text("About")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    Text(userProfile.bio)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.85) : .black.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                    // Looking for section
                    if !userProfile.lookingFor.isEmpty {
                        Text("Looking for")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        
                        HStack {
                            ForEach(userProfile.lookingFor, id: \.self) { item in
                                Text(item)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Color.red)
                                    .cornerRadius(16)
                            }
                            Spacer()
                        }
                    }
                    
                    // Education
                    if !userProfile.education.isEmpty {
                        Text("Education")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        
                        // School and education level combined
                        if !userProfile.school.isEmpty {
                            Text("\(userProfile.school), \(userProfile.education)")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.85) : .black.opacity(0.85))
                        } else {
                            Text(userProfile.education)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.85) : .black.opacity(0.85))
                        }
                    }
                    
                    // Horoscope
                    if !userProfile.horoscope.isEmpty {
                        Text("Horoscope")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        
                        HStack(spacing: 8) {
                            Text(userProfile.horoscope)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.85) : .black.opacity(0.85))
                            
                            // Horoscope emoji with styled background
                            Text(getHoroscopeEmoji(for: userProfile.horoscope))
                                .font(.system(size: 18))
                        }
                    }
                    
                    // Interests
                    if !userProfile.interests.isEmpty {
                        Text("Interest")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        
                        // Simple horizontal flow for interests
                        FlowingInterests(items: userProfile.interests)
                    }
                    
                    // City and distance info
                    VStack {
                        Text(userProfile.city)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        
                        Text("\(userProfile.distance) km uzakta")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    
                    // Profile completion percentage - moved inside the main content VStack
                    VStack(spacing: 10) {
                        HStack {
                            Text("Profil Tamamlama")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            
                            Spacer()
                            
                            Text("\(completionPercentage)%")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(completionPercentage == 100 ? .green : .blue)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 8)
                                    .opacity(0.3)
                                    .foregroundColor(.gray)
                                    .cornerRadius(4)
                                
                                // Filled portion
                                Rectangle()
                                    .frame(width: geometry.size.width * CGFloat(completionPercentage) / 100, height: 8)
                                    .foregroundColor(completionPercentage == 100 ? Color.green : Color.blue)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        if completionPercentage < 100 {
                            Button(action: {
                                // Close this sheet and open the edit sheet
                                presentationMode.wrappedValue.dismiss()
                                // Wait a moment before showing the edit sheet
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showEditSheet = true
                                }
                            }) {
                                Text("Profilini tamamla")
                                    .font(.system(size: 15))
                                    .foregroundColor(.blue)
                                    .padding(.top, 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        } else {
                            Text("Profil tamamlandı")
                                .font(.system(size: 15))
                                .foregroundColor(.green)
                                .padding(.top, 5)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.vertical, 15)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .background(Color(themeManager.isDarkMode ? .black : .white))
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .offset(y: -70) // Pull the card up to overlap with photo
                .padding(.bottom, -70) // Adjust scroll view content size
            }
            .edgesIgnoringSafeArea(.top)
        }
        .background(Color(themeManager.isDarkMode ? .black : .white))
        .onAppear {
            // Calculate profile completion when view appears
            completionPercentage = userProfile.calculateProfileCompletion()
        }
    }
    
    // Function to get horoscope emoji
    private func getHoroscopeEmoji(for horoscopeSign: String) -> String {
        let lowercaseHoroscope = horoscopeSign.lowercased()
        
        if lowercaseHoroscope.contains("koç") || lowercaseHoroscope.contains("aries") {
            return "♈️"
        } else if lowercaseHoroscope.contains("boğa") || lowercaseHoroscope.contains("taurus") {
            return "♉️"
        } else if lowercaseHoroscope.contains("ikizler") || lowercaseHoroscope.contains("gemini") {
            return "♊️"
        } else if lowercaseHoroscope.contains("yengeç") || lowercaseHoroscope.contains("cancer") {
            return "♋️"
        } else if lowercaseHoroscope.contains("aslan") || lowercaseHoroscope.contains("leo") {
            return "♌️"
        } else if lowercaseHoroscope.contains("başak") || lowercaseHoroscope.contains("virgo") {
            return "♍️"
        } else if lowercaseHoroscope.contains("terazi") || lowercaseHoroscope.contains("libra") {
            return "♎️"
        } else if lowercaseHoroscope.contains("akrep") || lowercaseHoroscope.contains("scorpio") {
            return "♏️"
        } else if lowercaseHoroscope.contains("yay") || lowercaseHoroscope.contains("sagittarius") {
            return "♐️"
        } else if lowercaseHoroscope.contains("oğlak") || lowercaseHoroscope.contains("capricorn") {
            return "♑️"
        } else if lowercaseHoroscope.contains("kova") || lowercaseHoroscope.contains("aquarius") {
            return "♒️"
        } else if lowercaseHoroscope.contains("balık") || lowercaseHoroscope.contains("pisces") {
            return "♓️"
        } else {
            return "⭐️" // Default
        }
    }
}

// Simplified interest layout that flows horizontally
struct FlowingInterests: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 10)
            ], spacing: 10) {
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
            Text(title)
                .font(.system(size: 15, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(18)
    }
}

#Preview {
    let themeManager = ThemeManager()
    return ProfileInfoSheetView(showEditSheet: .constant(false))
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .frame(height: 700)
} 