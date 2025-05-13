import SwiftUI
import UIKit

// Remove the incorrect import
// @_exported import class churcle.ThemeManager

struct ProfileSettingsSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Hesap")) {
                    SettingsRow(icon: "person.fill", title: "Profil Ayarları")
                    SettingsRow(icon: "bell.fill", title: "Bildirimler")
                    SettingsRow(icon: "lock.fill", title: "Gizlilik")
                }
                
                Section(header: Text("Uygulama")) {
                    SettingsRow(icon: "questionmark.circle.fill", title: "Yardım")
                    SettingsRow(icon: "info.circle.fill", title: "Hakkında")
                    
                    ThemeSwitchView()
                }
                
                Button(action: {
                    // Logout action
                }) {
                    Text("Çıkış Yap")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.sheetBackground)
        }
        .background(Color.sheetBackground)
    }
}

#Preview {
    ProfileSettingsSheetView()
        .environmentObject(ThemeManager())
} 