import SwiftUI
import PhotosUI

struct MessageSheetView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let user: User
    @Binding var isPresented: Bool
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var offset = CGSize.zero
    @State private var selectedItem: PhotosPickerItem? = nil
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar for sheet
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            // Profile header
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(user.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding()
                
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
            
            // Messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 40)
                            
                            Text("Sohbete başla")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Text("Hemen ilk mesajı göndererek sohbeti başlatabilirsin")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    } else {
                        ForEach(messages) { message in
                            MessageBubble(message: message, dateFormatter: dateFormatter)
                        }
                    }
                }
                .padding()
            }
            .background(Color.sheetBackground)
            
            // Message input bar
            VStack {
                Divider()
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Image(systemName: "photo.fill")
                            .foregroundColor(Color.appAccent)
                            .font(.system(size: 22))
                    }
                    
                    TextField("Mesajınız...", text: $messageText)
                        .padding(12)
                        .background(Color.lightGrayButton)
                        .cornerRadius(20)
                        .foregroundColor(.primary)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color.appAccent)
                            .font(.system(size: 22))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .padding(.bottom, 30)
            }
            .background(Color.sheetBackground)
        }
        .background(Color.sheetBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .offset(y: offset.height)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height > 0 {
                        offset = gesture.translation
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.height > 100 {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                }
        )
        .onChange(of: selectedItem) { oldValue, newValue in
            if let item = newValue {
                handleSelectedItem(item)
            }
        }
        .onDisappear {
            isPresented = false
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
    
    private func handleSelectedItem(_ item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let message = Message(
                    content: "",
                    isFromUser: true,
                    timestamp: Date(),
                    image: image
                )
                messages.append(message)
                
                // Simulate response after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let responses = [
                        "Harika bir fotoğraf! 📸",
                        "Çok güzel görünüyor! 😊",
                        "Wow, muhteşem! ✨",
                        "Teşekkürler, bayıldım! 🌟",
                        "Harika bir paylaşım! 👏"
                    ]
                    let response = Message(
                        content: responses.randomElement() ?? "Güzel fotoğraf!",
                        isFromUser: false,
                        timestamp: Date()
                    )
                    messages.append(response)
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = Message(content: messageText, isFromUser: true, timestamp: Date())
        messages.append(userMessage)
        messageText = ""
        
        // Simulate response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let responses = [
                "Harika! Nasılsın?",
                "Çok teşekkür ederim 😊",
                "Bu çok ilginç!",
                "Seninle tanışmak güzel",
                "Ne yapmayı seversin?"
            ]
            let response = Message(
                content: responses.randomElement() ?? "Merhaba!",
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(response)
        }
    }
} 