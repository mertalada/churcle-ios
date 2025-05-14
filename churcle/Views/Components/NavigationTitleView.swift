import SwiftUI
import UIKit

struct NavigationTitleView: View {
    enum SettingsType {
        case none
        case profile    // Settings icon for ProfileScreen
        case options    // Volume/options controls for HomeScreen
    }
    
    var settingsType: SettingsType = .none
    var isCenter = false
    @State private var showSettings = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 6) {
            if isCenter {
                Spacer()
            }
            
            // Logo image
            Image("churcle_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Text("churcle")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(red: 33 / 255, green: 208 / 255, blue: 3 / 255))
            
            Spacer()
            
            // Different settings buttons based on type
            switch settingsType {
            case .profile:
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                }
                .sheet(isPresented: $showSettings) {
                    ProfileSettingsSheetView(isSheetShowing: $showSettings)
                        .id("ProfileSettingsSheetView")  // Give a stable ID to preserve state
                        .presentationDetents([.fraction(0.95)])
                        .presentationCornerRadius(30)
                        .presentationBackground(themeManager.isDarkMode ? Color.clear : Color.sheetBackground)
                        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                }
                
            case .options:
                Button(action: {
                    showSettings = true
                }) {
                    Image("discoverysettings_logo")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                }
                .sheet(isPresented: $showSettings) {
                    OptionsSheetView()
                        .presentationDetents([.fraction(0.95)])
                        .presentationCornerRadius(30)
                        .presentationBackground(Color.sheetBackground)
                }
                
            case .none:
                EmptyView()
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
        .background(themeManager.isDarkMode ? Color.black : Color.white)
    }
}

// Helper views
struct SettingsRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue) 
                .frame(width: 30)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
    }
}

#Preview {
    
    let themeManager = ThemeManager()
     VStack(spacing: 20) {
        NavigationTitleView(settingsType: .profile)
            .padding()
            .background(Color.black)
        
        NavigationTitleView(settingsType: .options)
            .padding()
            .background(Color.black)
        
        NavigationTitleView(isCenter: true)
            .padding()
            .background(Color.black)
    }
    .environmentObject(themeManager)
    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
} 

