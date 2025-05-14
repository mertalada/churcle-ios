import SwiftUI
import UIKit

// Açıkça module adıyla tanımlayalım
public class ThemeManager: ObservableObject {
    @Published public var isDarkMode: Bool {
        didSet {
            // Immediately update UI appearance
            applyTheme()
            
            // Save to UserDefaults
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            
            // Force UI update
            forceUIRefresh()
            
            // Update any AppStorage references in the app
            syncAppStorageWithThemeManager()
            
            // Increment the viewID to force view refresh
            self.viewID = UUID()
        }
    }
    
    // This UUID changes whenever theme changes to force view refresh
    @Published public var viewID: UUID = UUID()
    
    public init() {
        // Initialize from UserDefaults
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        applyTheme()
    }
    
    /// Main function to apply theme changes across the entire app
    public func applyTheme() {
        // Configure UIKit appearance
        configureTabBarAppearance()
        configureNavigationBarAppearance()
        
        // Configure other UI elements if needed
        configureUIElements()
        
        // Make sure AppStorage values are synchronized
        syncAppStorageWithThemeManager()
    }
    
    /// Ensures all @AppStorage("isDarkMode") variables in the app stay in sync with ThemeManager
    private func syncAppStorageWithThemeManager() {
        // This synchronizes ThemeManager's state with UserDefaults
        // so @AppStorage("isDarkMode") will pick up the changes
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        
        // Force update notification for UserDefaults
        NotificationCenter.default.post(
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
        // Directly update ColorEnvironment shared instance
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // No need to check if it's castable - it's a concrete class
            ColorEnvironment.shared.isDarkMode = self.isDarkMode
        }
    }
    
    /// Applies aggressive styling to fix tab bar appearance issues in dark mode
    public func configureTabBarAppearance() {
        // Create a new appearance instance each time
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Color.uiTabBarBackground
        
        // Set background to completely opaque black in dark mode
        if isDarkMode {
            // Force black for the appearance with full opacity
            appearance.backgroundColor = .black
            appearance.backgroundEffect = nil // Remove any background effects/blur
        }
        
        // Update the global appearance proxy
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = Color.uiTabBarItemColor
        UITabBar.appearance().unselectedItemTintColor = Color.uiTabBarItemUnselectedColor
        
        // Force tab bar background in case appearance doesn't apply
        UITabBar.appearance().barTintColor = isDarkMode ? .black : .white
        UITabBar.appearance().backgroundColor = isDarkMode ? .black : .white
            
        // Direct update to tab bar instances
        DispatchQueue.main.async {
            if #available(iOS 15.0, *) {
                for connectedScene in UIApplication.shared.connectedScenes {
                    if let windowScene = connectedScene as? UIWindowScene {
                        for window in windowScene.windows {
                            if let tabBarController = window.rootViewController as? UITabBarController {
                                tabBarController.tabBar.standardAppearance = appearance
                                tabBarController.tabBar.scrollEdgeAppearance = appearance
                                tabBarController.tabBar.tintColor = Color.uiTabBarItemColor
                                tabBarController.tabBar.unselectedItemTintColor = Color.uiTabBarItemUnselectedColor
                                
                                // Force explicit background color setting
                                tabBarController.tabBar.backgroundColor = Color.uiTabBarBackground
                                tabBarController.tabBar.barTintColor = self.isDarkMode ? .black : .white
                                
                                // Force appearance update at the view level
                                self.forceTabBarBackgroundColor(tabBarController.tabBar)
                                
                                tabBarController.tabBar.setNeedsLayout()
                                tabBarController.tabBar.layoutIfNeeded()
                            }
                        }
                    }
                }
            } else {
                for window in UIApplication.shared.windows {
                    if let tabBarController = window.rootViewController as? UITabBarController {
                        tabBarController.tabBar.standardAppearance = appearance
                        tabBarController.tabBar.scrollEdgeAppearance = appearance
                        tabBarController.tabBar.tintColor = Color.uiTabBarItemColor
                        tabBarController.tabBar.unselectedItemTintColor = Color.uiTabBarItemUnselectedColor
                        
                        // Force explicit background color setting
                        tabBarController.tabBar.backgroundColor = Color.uiTabBarBackground
                        tabBarController.tabBar.barTintColor = self.isDarkMode ? .black : .white
                        
                        // Force appearance update at the view level
                        self.forceTabBarBackgroundColor(tabBarController.tabBar)
                                
                        tabBarController.tabBar.setNeedsLayout()
                        tabBarController.tabBar.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    // Extra method to force the tab bar background color by manipulating its subviews
    private func forceTabBarBackgroundColor(_ tabBar: UITabBar) {
        // This walks through all subviews of the tab bar and forces any background views to be black
        for subview in tabBar.subviews {
            // Identify background views by tag or class and force color
            if let backgroundView = subview as? UIVisualEffectView {
                backgroundView.backgroundColor = isDarkMode ? .black : .white
                backgroundView.effect = nil // Remove blur effect
                
                // Force all subviews to be the correct color too
                for innerView in backgroundView.subviews {
                    innerView.backgroundColor = isDarkMode ? .black : .white
                }
            }
            
            // Force any other background-like views to have proper color
            if subview.frame.height > tabBar.frame.height * 0.7 {
                subview.backgroundColor = isDarkMode ? .black : .white
            }
            
            // Check one level deeper if needed
            for innerView in subview.subviews {
                if innerView.frame.height > tabBar.frame.height * 0.7 {
                    innerView.backgroundColor = isDarkMode ? .black : .white
                }
            }
        }
    }
    
    private func configureNavigationBarAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = isDarkMode ? .black : .white
        navAppearance.titleTextAttributes = [.foregroundColor: isDarkMode ? UIColor.white : UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
    
    private func configureUIElements() {
        // Custom UI element appearance settings
        UISwitch.appearance().onTintColor = isDarkMode ? .systemBlue : .systemGreen
        UISegmentedControl.appearance().selectedSegmentTintColor = isDarkMode ? .darkGray : .white
        
        // Additional UI elements that need forced theming
        configureSheetsAndModals()
    }
    
    private func configureSheetsAndModals() {
        // Set appearance for sheets and modals
        if #available(iOS 15.0, *) {
            // UISheetPresentationController doesn't have an appearance() method
            // We'll need to configure sheets individually when presented
            
            // For iOS 15+ we can modify presented views directly
            if isDarkMode {
                // Force dark background for sheets
                for connectedScene in UIApplication.shared.connectedScenes {
                    if let windowScene = connectedScene as? UIWindowScene {
                        for window in windowScene.windows {
                            // Look for presented view controllers that might be sheets/modals
                            if let presentedVC = window.rootViewController?.presentedViewController {
                                presentedVC.view.backgroundColor = .black
                                
                                // Force all direct subviews to be black too
                                for subview in presentedVC.view.subviews {
                                    if subview is UIScrollView || 
                                       subview is UIStackView || 
                                       String(describing: type(of: subview)).contains("Background") {
                                        subview.backgroundColor = .black
                                    }
                                }
                                
                                // Prevent automatic dismissal due to theme change
                                if let sheetController = presentedVC.presentationController as? UISheetPresentationController {
                                    // Keep the sheet visible during theme changes
                                    sheetController.largestUndimmedDetentIdentifier = sheetController.selectedDetentIdentifier
                                }
                            }
                        }
                    }
                }
            } else {
                // Similar logic for light mode
                for connectedScene in UIApplication.shared.connectedScenes {
                    if let windowScene = connectedScene as? UIWindowScene {
                        for window in windowScene.windows {
                            if let presentedVC = window.rootViewController?.presentedViewController {
                                presentedVC.view.backgroundColor = .white
                                
                                for subview in presentedVC.view.subviews {
                                    if subview is UIScrollView || 
                                       subview is UIStackView || 
                                       String(describing: type(of: subview)).contains("Background") {
                                        subview.backgroundColor = .white
                                    }
                                }
                                
                                // Prevent automatic dismissal due to theme change
                                if let sheetController = presentedVC.presentationController as? UISheetPresentationController {
                                    // Keep the sheet visible during theme changes
                                    sheetController.largestUndimmedDetentIdentifier = sheetController.selectedDetentIdentifier
                                }
                            }
                        }
                    }
                }
            }
        } 
    }
    
    // UIKit yenileme işlemi - tema değişikliğini tüm bileşenlere zorla duyurmak için
    private func forceUIRefresh() {
        // Forced update to try to refresh the UI state
        DispatchQueue.main.async {
            // iOS 15+ için güncellenmiş yöntem
            if #available(iOS 15.0, *) {
                // Get connected scenes
                for connectedScene in UIApplication.shared.connectedScenes {
                    if let windowScene = connectedScene as? UIWindowScene {
                        for window in windowScene.windows {
                            // Force layout refresh for TabBar
                            if let tabBarController = window.rootViewController as? UITabBarController {
                                tabBarController.tabBar.setNeedsLayout()
                                tabBarController.tabBar.layoutIfNeeded()
                                tabBarController.viewDidLayoutSubviews()
                            }
                            
                            // Force a full window refresh for good measure
                            window.rootViewController?.view.setNeedsLayout()
                            window.rootViewController?.view.layoutIfNeeded()
                            
                            // Also force refresh any presented controllers (sheets, etc)
                            if let presented = window.rootViewController?.presentedViewController {
                                presented.view.setNeedsLayout()
                                presented.view.layoutIfNeeded()
                            }
                        }
                    }
                }
            } else {
                // iOS 15 öncesi için eski yöntem
                for window in UIApplication.shared.windows {
                    // Force layout refresh for TabBar
                    if let tabBarController = window.rootViewController as? UITabBarController {
                        tabBarController.tabBar.setNeedsLayout()
                        tabBarController.tabBar.layoutIfNeeded()
                        tabBarController.viewDidLayoutSubviews()
                    }
                    
                    // Force a full window refresh for good measure
                    window.rootViewController?.view.setNeedsLayout()
                    window.rootViewController?.view.layoutIfNeeded()
                    
                    // Also force refresh any presented controllers (sheets, etc)
                    if let presented = window.rootViewController?.presentedViewController {
                        presented.view.setNeedsLayout()
                        presented.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    public func toggleTheme() {
        isDarkMode.toggle()
    }
} 