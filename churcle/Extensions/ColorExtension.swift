import SwiftUI
import UIKit

// Custom DismissAction for sheets
struct DismissAction {
    let action: () -> Void
}

// Environment key for custom dismiss action
private struct DismissActionKey: EnvironmentKey {
    static let defaultValue = DismissAction(action: {})
}

extension EnvironmentValues {
    var dismissAction: DismissAction {
        get { self[DismissActionKey.self] }
        set { self[DismissActionKey.self] = newValue }
    }
}

// This class allows colors to get updates when theme changes
class ColorEnvironment: ObservableObject {
    @Published var isDarkMode: Bool
    static let shared = ColorEnvironment()
    
    // Use a singleton pattern to ensure only one instance exists
    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // Listen for theme changes via NotificationCenter
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleThemeChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Color {
    static let appBackground = Color("AppColors")
    static let appAccent = Color("AccentColor")
    
    // Theme bağımlı background color tanımları
    static var sheetBackground: Color {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? Color.black : Color(UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1.0))
    }
    
    static var tabBarBackground: Color {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? Color.black : Color.white
    }
    
    static var tabBarItemColor: Color {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? Color.white : Color.black
    }
    
    static var tabBarItemUnselectedColor: Color {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? Color.white.opacity(0.7) : Color.gray
    }
    
    static var navBarBackground: Color {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? Color.black : Color.white
    }
    
    static var appText: Color {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? Color.white : Color.black
    }
    
    static var lightGrayButton: Color {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? Color.gray.opacity(0.3) : Color(UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0))
    }
    
    // UIKit için renk dönüşümleri - UIAppearance API'leri için
    static var uiTabBarBackground: UIColor {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? .black : .white
    }
    
    static var uiTabBarItemColor: UIColor {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? .white : .black
    }
    
    static var uiTabBarItemUnselectedColor: UIColor {
        let isDarkMode = ColorEnvironment.shared.isDarkMode
        return isDarkMode ? UIColor.white.withAlphaComponent(0.7) : .gray
    }
} 