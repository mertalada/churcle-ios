import SwiftUI
import UIKit

// Remove the incorrect import
// @_exported import class churcle.ThemeManager

struct ThemeSwitchView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var keepSheetPresented: Bool
    
    // Default initializer for previews and cases without binding
    init(keepSheetPresented: Binding<Bool> = .constant(true)) {
        self._keepSheetPresented = keepSheetPresented
    }
    
    var body: some View {
        Toggle(isOn: Binding<Bool>(
            get: { themeManager.isDarkMode },
            set: { newValue in
                // Explicitly maintain sheet presentation
                let oldValue = themeManager.isDarkMode
                if oldValue != newValue {
                    // Manual update
                    themeManager.isDarkMode = newValue
                    
                    // Make sure the sheet stays presented
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.keepSheetPresented = true
                    }
                }
            }
        )) {
            HStack(spacing: 12) {
                Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundColor(themeManager.isDarkMode ? .white : .yellow)
                
                Text(themeManager.isDarkMode ? "Dark Mode" : "Light Mode")
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .padding(.vertical, 8)
        // Use an ID based on theme to force redraw
        .id("ThemeSwitch-\(themeManager.isDarkMode ? "dark" : "light")")
    }
}

#Preview {
    ThemeSwitchView()
        .environmentObject(ThemeManager())
        .padding()
} 