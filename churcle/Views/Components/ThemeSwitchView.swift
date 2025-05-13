import SwiftUI
import UIKit

// Remove the incorrect import
// @_exported import class churcle.ThemeManager

struct ThemeSwitchView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Toggle(isOn: $themeManager.isDarkMode) {
            HStack(spacing: 12) {
                Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundColor(themeManager.isDarkMode ? .white : .yellow)
                
                Text(themeManager.isDarkMode ? "Dark Mode" : "Light Mode")
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .padding(.vertical, 8)
    }
}

#Preview {
    ThemeSwitchView()
        .environmentObject(ThemeManager())
        .padding()
} 