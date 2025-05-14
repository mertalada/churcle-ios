//
//  churcleApp.swift
//  churcle
//
//  Created by Mert Aladağ on 6.05.2025.
//

import SwiftUI

@main
struct churcleApp: App {
    // Create a single source of truth for theme management
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Default to light mode on first launch by setting AppStorage value
        if UserDefaults.standard.object(forKey: "isDarkMode") == nil {
            UserDefaults.standard.set(false, forKey: "isDarkMode")
        }
        
        // Force UI appearance right at app startup
        // Using a temporary instance to configure the global appearance
        ThemeManager().applyTheme()
        
        // Set up appearance providers for UIKit elements
        configureGlobalUIAppearance()
    }
    
    private func configureGlobalUIAppearance() {
        // Configure UINavigationBar appearance for the whole app
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // Configure TabBar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = isDarkMode ? .black : .white
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Configure NavigationBar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.backgroundColor = isDarkMode ? .black : .white
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                .forceRefreshWithThemeManager(themeManager)
                .onAppear {
                    // Preserve sheet presentation on app startup
                    setupSheetDismissalPrevention()
                    
                    // Force theme to apply on app launch with delay to ensure UI is ready
                    themeManager.applyTheme()
                    
                    // Apply theme again after a short delay to catch any late-loading UI
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        themeManager.applyTheme()
                    }
                }
                .onChange(of: themeManager.isDarkMode) { _, _ in
                    // This ensures that every time dark mode changes, UI updates immediately
                    themeManager.applyTheme()
                    
                    // Prevent sheets from being dismissed during theme changes
                    setupSheetDismissalPrevention()
                    
                    // Ensure presented sheets remain visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if #available(iOS 15.0, *) {
                            for connectedScene in UIApplication.shared.connectedScenes {
                                if let windowScene = connectedScene as? UIWindowScene {
                                    for window in windowScene.windows {
                                        if let presentedVC = window.rootViewController?.presentedViewController {
                                            // Force preserve sheets
                                            presentedVC.view.setNeedsLayout()
                                            presentedVC.view.layoutIfNeeded()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
    
    /// Helper function to prevent sheet dismissal during theme changes
    private func setupSheetDismissalPrevention() {
        // This extends UIPresentationController to prevent automatic dismissal
        if #available(iOS 15.0, *) {
            for connectedScene in UIApplication.shared.connectedScenes {
                if let windowScene = connectedScene as? UIWindowScene {
                    for window in windowScene.windows {
                        if let presentedVC = window.rootViewController?.presentedViewController,
                           let sheetController = presentedVC.presentationController as? UISheetPresentationController {
                            // Explicitly prevent dismissal during theme changes
                            DispatchQueue.main.async {
                                sheetController.animateChanges {
                                    // Make sure detents stay set
                                    if sheetController.selectedDetentIdentifier != nil {
                                        sheetController.selectedDetentIdentifier = sheetController.selectedDetentIdentifier
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
