import SwiftUI
import UIKit

extension Color {
    static let appBackground = Color("AppColors")
    static let appAccent = Color("AccentColor")
    
    // Theme bağımlı background color tanımları
    static var sheetBackground: Color {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? Color.black : Color(UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1.0))
    }
    
    static var tabBarBackground: Color {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? Color.black : Color.white
    }
    
    static var tabBarItemColor: Color {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? Color.white : Color.black
    }
    
    static var tabBarItemUnselectedColor: Color {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? Color.white.opacity(0.7) : Color.gray
    }
    
    static var navBarBackground: Color {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? Color.black : Color.white
    }
    
    static var appText: Color {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? Color.white : Color.black
    }
    
    static var lightGrayButton: Color {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? Color.gray.opacity(0.3) : Color(UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0))
    }
    
    // UIKit için renk dönüşümleri - UIAppearance API'leri için
    static var uiTabBarBackground: UIColor {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? .black : .white
    }
    
    static var uiTabBarItemColor: UIColor {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? .white : .black
    }
    
    static var uiTabBarItemUnselectedColor: UIColor {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        return isDarkMode ? UIColor.white.withAlphaComponent(0.7) : .gray
    }
} 