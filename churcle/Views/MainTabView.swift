import SwiftUI
import UIKit

// Extend UITabBar to add custom height
extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 80 // Increase tab bar height
        return size
    }
}

struct MainTabView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab = 0
    @State private var matches: Set<User> = []
    @State private var likes: Int = 0
    @State private var showChatSheet = false
    @State private var selectedChatUser: User?
    @State private var lastMessages: [UUID: (String, Date)] = [:]
    @State private var messageHistory: [UUID: [Message]] = [:]
    @State private var isMessageSheetPresented = false
    @State private var selectedMessageUser: User?
    
    static var likes: Int = 0
    
    func updateTabBarAppearance() {
        // Call the ThemeManager's configureTabBarAppearance method directly
        themeManager.configureTabBarAppearance()
        
        // Additional force refresh specific to tab bar
        DispatchQueue.main.async {
            if #available(iOS 15.0, *) {
                for connectedScene in UIApplication.shared.connectedScenes {
                    if let windowScene = connectedScene as? UIWindowScene {
                        for window in windowScene.windows {
                            if let tabBarController = window.rootViewController as? UITabBarController {
                                // Force redraw of tab bar 
                                tabBarController.tabBar.setNeedsDisplay()
                                tabBarController.tabBar.layoutIfNeeded()
                                
                                // Explicitly set background color
                                tabBarController.tabBar.backgroundColor = Color.uiTabBarBackground
                                
                                // Explicitly update tab bar items
                                tabBarController.tabBar.items?.forEach { item in
                                    item.setTitleTextAttributes([.foregroundColor: Color.uiTabBarItemColor], for: .normal)
                                }
                            }
                        }
                    }
                }
            } else {
                for window in UIApplication.shared.windows {
                    if let tabBarController = window.rootViewController as? UITabBarController {
                        // Force redraw of tab bar
                        tabBarController.tabBar.setNeedsDisplay()
                        tabBarController.tabBar.layoutIfNeeded()
                        
                        // Explicitly set background color
                        tabBarController.tabBar.backgroundColor = Color.uiTabBarBackground
                        
                        // Explicitly update tab bar items
                        tabBarController.tabBar.items?.forEach { item in
                            item.setTitleTextAttributes([.foregroundColor: Color.uiTabBarItemColor], for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.appBackground.ignoresSafeArea()
            
            // Main TabView - set to a lower ZIndex
            ZStack {
                TabView(selection: $selectedTab) {
                    HomeScreen(matches: $matches, 
                        likes: $likes,
                        onMessageSheetChange: { isPresented in
                            isMessageSheetPresented = isPresented
                        },
                        onSelectMessageUser: { user in
                            selectedMessageUser = user
                        }
                    )
                    .tabItem {
                        Image("churcle_logo")
                            .renderingMode(selectedTab == 0 ? .original : .template)
                    }
                    .tag(0)
                    
                    DiscoverScreen()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                        }
                        .tag(1)
                    
                    MatchScreen(matches: $matches)
                        .tabItem {
                            Image(systemName: "star.fill")
                        }
                        .tag(2)
                    
                    ChatScreen(
                        matches: $matches,
                        lastMessages: lastMessages,
                        onChatSelected: { user in
                            selectedChatUser = user
                            showChatSheet = true
                        },
                        onNavigateToHome: {
                            selectedTab = 0 // Navigate to HomeScreen
                        }
                    )
                        .tabItem {
                            Image(systemName: "message.fill")
                        }
                        .tag(3)
                    
                    ProfileScreen(matches: $matches)
                        .tabItem {
                            Image(systemName: "person.fill")
                        }
                        .tag(4)
                }
                .accentColor(Color.appAccent)
                .background(Color.tabBarBackground)
                .onAppear {
                    // Apply theme immediately on appear and directly update tab bar
                    themeManager.applyTheme()
                    updateTabBarAppearance()
                    
                    // Position icons at the bottom - iOS 15+
                    if #available(iOS 15.0, *) {
                        for connectedScene in UIApplication.shared.connectedScenes {
                            if let windowScene = connectedScene as? UIWindowScene {
                                for window in windowScene.windows {
                                    if let tabBarController = window.rootViewController as? UITabBarController {
                                        tabBarController.tabBar.items?.forEach { item in
                                            // More aggressive positioning
                                            item.imageInsets = UIEdgeInsets(top: 25, left: 0, bottom: -25, right: 0)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // iOS 15 öncesi için
                        if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                            tabBarController.tabBar.items?.forEach { item in
                                item.imageInsets = UIEdgeInsets(top: 25, left: 0, bottom: -25, right: 0)
                            }
                        }
                    }
                }
                .onChange(of: colorScheme) { _, _ in
                    // Update when system color scheme changes
                    updateTabBarAppearance()
                }
                .forceRefreshWithThemeManager(themeManager) // Use the correct instance
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .ignoresSafeArea(edges: [.bottom])
                // Attach sheets to TabView for proper presentation
                .sheet(isPresented: $showChatSheet) {
                    if let user = selectedChatUser {
                    ChatSheetView(
                        user: user,
                        isPresented: $showChatSheet,
                        lastMessage: Binding(
                            get: { lastMessages[user.id] },
                            set: { lastMessages[user.id] = $0 }
                        ),
                        messages: Binding(
                            get: { messageHistory[user.id] ?? [] },
                            set: { messageHistory[user.id] = $0 }
                        )
                    )
                        .presentationDetents([.fraction(0.95)])
                        .presentationCornerRadius(30)
                        .presentationBackground(Color.sheetBackground)
            }
                }
                .sheet(isPresented: $isMessageSheetPresented) {
                    if let selectedMessageUser = selectedMessageUser {
                    MessageSheetView(
                        user: selectedMessageUser,
                        isPresented: $isMessageSheetPresented
                    )
                        .presentationDetents([.fraction(0.95)])
                        .presentationCornerRadius(30)
                        .presentationBackground(Color.sheetBackground)
                }
                }
            }
            .zIndex(0) // Lower ZIndex for the TabView
            
            // Removed separate implementations of sheets since they are now properly attached to TabView
        }
        .onChange(of: showChatSheet) { oldValue, newValue in
            if !newValue {
                selectedChatUser = nil
            }
        }
        .onChange(of: likes) { oldValue, newValue in
            MainTabView.likes = newValue
        }
        .animation(.default, value: isMessageSheetPresented)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .onChange(of: themeManager.isDarkMode) { oldValue, newValue in
            // Apply theme changes immediately when toggled
            themeManager.applyTheme()
            // Also directly update tab bar appearance
            updateTabBarAppearance()
            
            // Force UI update immediately and also after a slight delay to ensure changes are applied
            DispatchQueue.main.async {
                updateTabBarAppearance()
                
                // Force explicit color setting on the tab bar
                if #available(iOS 15.0, *) {
                    for connectedScene in UIApplication.shared.connectedScenes {
                        if let windowScene = connectedScene as? UIWindowScene {
                            for window in windowScene.windows {
                                if let tabBarController = window.rootViewController as? UITabBarController {
                                    // Explicitly set tab bar background
                                    tabBarController.tabBar.barTintColor = newValue ? .black : .white
                                    tabBarController.tabBar.backgroundColor = Color.uiTabBarBackground
                                    
                                    // Explicitly add a solid background color view to force color
                                    if let subviews = tabBarController.tabBar.subviews.first?.subviews {
                                        for view in subviews {
                                            view.backgroundColor = newValue ? .black : .white
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Similar approach for iOS < 15
                    for window in UIApplication.shared.windows {
                        if let tabBarController = window.rootViewController as? UITabBarController {
                            tabBarController.tabBar.barTintColor = newValue ? .black : .white
                            tabBarController.tabBar.backgroundColor = Color.uiTabBarBackground
                            
                            // Explicitly add a solid background color view to force color
                            if let subviews = tabBarController.tabBar.subviews.first?.subviews {
                                for view in subviews {
                                    view.backgroundColor = newValue ? .black : .white
                                }
                            }
                        }
                    }
                }
                
                // Also attempt an update after a brief delay for stubborn UI elements
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    updateTabBarAppearance()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ThemeManager())
} 