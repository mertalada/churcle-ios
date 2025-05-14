import SwiftUI

/// This extension helps migrating from @AppStorage("isDarkMode") to ThemeManager
/// by providing a way to observe changes to ThemeManager and update AppStorage values
extension View {
    /// Apply ThemeManager to any view that previously used @AppStorage("isDarkMode")
    /// This ensures consistent theme across the app
    func applyThemeManager(_ themeManager: ThemeManager) -> some View {
        self.modifier(ThemeManagerModifier(themeManager: themeManager))
    }
}

/// Custom modifier that ensures theme consistency
struct ThemeManagerModifier: ViewModifier {
    @ObservedObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .onAppear {
                // Ensure UserDefaults is synced with ThemeManager
                UserDefaults.standard.set(themeManager.isDarkMode, forKey: "isDarkMode")
            }
    }
}

/// View extension to create helpers for theme colors
extension View {
    /// Apply consistent background color based on current theme
    func themedBackground(_ themeManager: ThemeManager) -> some View {
        self.background(themeManager.isDarkMode ? Color.black : Color.white)
    }
    
    /// Apply consistent foreground color based on current theme
    func themedForeground(_ themeManager: ThemeManager) -> some View {
        self.foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)
    }
}

/// Migration helper to reduce duplication in view files
/// This struct helps with updating screen files that use @AppStorage
struct ThemeMigrationHelper: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .onChange(of: themeManager.isDarkMode) { oldValue, newValue in
                // Force update when theme changes
                UserDefaults.standard.set(newValue, forKey: "isDarkMode")
            }
    }
}

/// Helper modifier that forces view redraw when theme changes
struct ForceViewRefreshModifier: ViewModifier {
    @ObservedObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .id(themeManager.viewID)
    }
}

extension View {
    /// Apply this modifier to any view that used @AppStorage("isDarkMode")
    func migrateToThemeManager() -> some View {
        self.modifier(ThemeMigrationHelper())
    }
    
    /// Force redraw this view when theme changes
    func forceRefreshOnThemeChange() -> some View {
        // This allows default usage without direct reference
        return EnvironmentThemeManagerReader { themeManager in
            self.modifier(ForceViewRefreshModifier(themeManager: themeManager))
        }
    }
    
    /// Force redraw this view when theme changes with a specific ThemeManager
    func forceRefreshWithThemeManager(_ themeManager: ThemeManager) -> some View {
        self.modifier(ForceViewRefreshModifier(themeManager: themeManager))
    }
}

/// Helper to safely read ThemeManager from environment
struct EnvironmentThemeManagerReader<Content: View>: View {
    @EnvironmentObject var themeManager: ThemeManager
    let content: (ThemeManager) -> Content
    
    init(@ViewBuilder content: @escaping (ThemeManager) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(themeManager)
    }
} 