import SwiftUI
import UIKit

// Remove the incorrect import
// @_exported import class churcle.ThemeManager

struct ProfileSettingsSheetView: View {
    @Environment(\.presentationMode) var presentationMode
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
        ZStack {
            // Theme-appropriate background
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            NavigationView {
                List {
                    Section(header: Text("Hesap")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .medium))) {
                        SettingsRow(icon: "person.fill", title: "Profil Ayarları")
                        SettingsRow(icon: "bell.fill", title: "Bildirimler")
                        SettingsRow(icon: "lock.fill", title: "Gizlilik")
                    }
                    .listRowBackground(containerBackgroundColor)
                    
                    Section(header: Text("Uygulama")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .medium))) {
                        SettingsRow(icon: "questionmark.circle.fill", title: "Yardım")
                        SettingsRow(icon: "info.circle.fill", title: "Hakkında")
                        
                        // Pass the binding to ThemeSwitchView to prevent dismissal
                        ThemeSwitchView(keepSheetPresented: $isSheetShowing)
                    }
                    .listRowBackground(containerBackgroundColor)
                    
                    Button(action: {
                        // Logout action
                    }) {
                        Text("Çıkış Yap")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(containerBackgroundColor)
                    
                    Button(action: {
                        // Explicitly close the sheet
                        isSheetShowing = false
                    }) {
                        Text("Kapat")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(containerBackgroundColor)
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Ayarlar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kapat") {
                            isSheetShowing = false
                        }
                    }
                }
                .scrollContentBackground(.hidden)  // Hide default list background
                .background(backgroundColor)
                .id("ProfileSettingsListView-\(themeManager.isDarkMode ? "dark" : "light")")
            }
            .background(backgroundColor)
            .navigationViewStyle(StackNavigationViewStyle())
            // Force view refresh on theme changes but maintain sheet state
            .id("ProfileSettingsNavView-\(themeManager.isDarkMode ? "dark" : "light")")
        }
        .background(backgroundColor)
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
