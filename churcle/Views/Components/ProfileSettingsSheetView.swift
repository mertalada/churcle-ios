import SwiftUI
import UIKit

// Remove the incorrect import
// @_exported import class churcle.ThemeManager

// Helper class to make sheet dismissable
class SheetHostingController: UIHostingController<AnyView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable dismissal by swipe down
        isModalInPresentation = false
    }
}

struct ProfileSettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var isSheetShowing: Bool
    
    // Default initializer for cases where we don't need the binding
    init(isSheetShowing: Binding<Bool> = .constant(true)) {
        self._isSheetShowing = isSheetShowing
        
        // Force sheet background to be theme-appropriate
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = isDarkMode ? .black : UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1.0)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // Container background color
    var containerBackgroundColor: Color {
        return themeManager.isDarkMode ? Color(UIColor.systemGray6) : Color.white
    }
    
    // Background color based on theme
    var backgroundColor: Color {
        return themeManager.isDarkMode ? Color.black : Color(UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1.0))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                
                Text("Ayarlar")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Account section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Hesap")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "person.fill", title: "Profil Ayarları")
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal)
                            
                            SettingsRow(icon: "bell.fill", title: "Bildirimler")
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal)
                            
                            SettingsRow(icon: "lock.fill", title: "Gizlilik")
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                        }
                        .background(containerBackgroundColor)
                        .cornerRadius(15)
                        .shadow(color: themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.1), 
                                radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // App section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Uygulama")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Yardım")
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal)
                            
                            SettingsRow(icon: "info.circle.fill", title: "Hakkında")
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal)
                            
                            // Theme switcher
                            ThemeSwitchView(keepSheetPresented: $isSheetShowing)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                        }
                        .background(containerBackgroundColor)
                        .cornerRadius(15)
                        .shadow(color: themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.1), 
                                radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Logout button
                    Button(action: {
                        // Logout action
                    }) {
                        Text("Çıkış Yap")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(15)
                            .shadow(color: themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.1), 
                                    radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 20)
            }
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
    }
}

struct ProfileSettingsContainer: View {
    @State private var isSheetPresented = true
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Color.clear.sheet(isPresented: $isSheetPresented) {
            ProfileSettingsSheetView(isSheetShowing: $isSheetPresented)
                .environmentObject(themeManager)
        }
    }
}

#Preview {
    Group {
        ProfileSettingsSheetView()
            .environmentObject(ThemeManager())
            .preferredColorScheme(.dark)
        
        ProfileSettingsSheetView()
            .environmentObject(ThemeManager())
            .preferredColorScheme(.light)
    }
} 
