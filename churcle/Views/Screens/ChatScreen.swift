import SwiftUI

struct ChatScreen: View {
    @Binding var matches: Set<User>
    let lastMessages: [UUID: (String, Date)]
    var onChatSelected: (User) -> Void
    var onNavigateToHome: (() -> Void)? = nil
    @State private var unreadMessages: Set<UUID> = []
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // YENİ EŞLEŞMELER - üstte yatay scroll
                let newMatches = Array(matches).filter { lastMessages[$0.id] == nil }
                if !newMatches.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 18) {
                            ForEach(newMatches, id: \.id) { user in
                                Button(action: { onChatSelected(user) }) {
                                    VStack(spacing: 6) {
                                        Image(user.image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color(red: 33 / 255, green: 208 / 255, blue: 3 / 255), lineWidth: 2))
                                        Text(user.name)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    }
                    
                    // Düz çizgi ekle
                    Divider()
                        .background(Color.gray.opacity(0.5))
                        .padding(.horizontal)
                }
                
                // SOHBETLER - altta dikey liste
                let messagedMatches = Array(matches).filter { lastMessages[$0.id] != nil }
                if messagedMatches.isEmpty && newMatches.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "message.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Henüz eşleşme yok")
                            .font(.title2)
                            .fontWeight(.bold)
                        Button(action: {
                            onNavigateToHome?()
                        }) {
                            Text("Kaydırmaya başla")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                } else if messagedMatches.isEmpty && !newMatches.isEmpty {
                    // Eşleşme var ama hiç mesaj yok
                    Spacer()
                    VStack(spacing: 20) {
                         Image(systemName: "message.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Haydi ilk mesajı at")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List {
                        ForEach(messagedMatches, id: \.id) { user in
                            ChatRow(
                                user: user,
                                lastMessage: lastMessages[user.id],
                                onTap: {
                                    onChatSelected(user)
                                    unreadMessages.remove(user.id)
                                },
                                showUnread: unreadMessages.contains(user.id)
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                    .onAppear {
                        // İlk açılışta tüm mesajlı eşleşmeleri unread olarak işaretle
                        unreadMessages = Set(messagedMatches.map { $0.id })
                    }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationTitleView(settingsType: .none, isCenter: true)
                }
            }
        }
    }
}

struct ChatRow: View {
    let user: User
    let lastMessage: (String, Date)?
    let onTap: () -> Void
    var showUnread: Bool = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(user.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 16, weight: .semibold))
                    
                    if let (message, _) = lastMessage {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    } else {
                        Text("Yeni eşleşme")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if let (_, date) = lastMessage {
                    Text(dateFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text("Yeni")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                // Okunmamış mesaj bildirimi
                if showUnread {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 14, height: 14)
                        .padding(.leading, 4)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChatScreen(
        matches: .constant(Set(User.sampleUsers)),
        lastMessages: [:],
        onChatSelected: { _ in }
    )
} 
