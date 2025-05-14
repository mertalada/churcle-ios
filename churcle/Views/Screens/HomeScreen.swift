import SwiftUI

struct HomeScreen: View {
    @State private var users = User.sampleUsers
    @State private var currentIndex = 0
    @State private var cardOffset = CGSize.zero
    @State private var cardRotation = 0.0
    @State private var swipeState: SwipeState = .none
    @Binding var matches: Set<User>
    @Binding var likes: Int
    var onMatch: ((User) -> Void)? = nil
    @State private var showChatSheet = false
    @State private var selectedChatUser: User? = nil
    @State private var showMessageSheet = false
    var onMessageSheetChange: ((Bool) -> Void)?
    var onSelectMessageUser: ((User) -> Void)? = nil
    
    private var hasCards: Bool {
        currentIndex < users.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if hasCards {
                        CardStackView(
                            users: users,
                            currentIndex: $currentIndex,
                            cardOffset: $cardOffset,
                            cardRotation: $cardRotation,
                            swipeState: $swipeState,
                            matches: $matches,
                            onMatch: onMatch,
                            onDragChanged: { value in
                                cardOffset = value.translation
                                withAnimation(.interactiveSpring()) {
                                    cardRotation = Double(value.translation.width / 10)
                                    
                                    if value.translation.width > 50 {
                                        swipeState = .like
                                    } else if value.translation.width < -50 {
                                        swipeState = .nope
                                    } else {
                                        swipeState = .none
                                    }
                                }
                            },
                            onDragEnded: { value in
                                handleSwipeEnd(value)
                            },
                            onRewind: rewindCard,
                            onSwipeLeft: { swipeCard(direction: .left) },
                            onSuperLike: handleSuperLike,
                            onSwipeRight: { swipeCard(direction: .right) },
                            onMessage: {
                                if hasCards {
                                    showMessageSheet = true
                                    onMessageSheetChange?(true)
                                    onSelectMessageUser?(users[currentIndex])
                                }
                            }
                        )
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Button(action: rewindCard) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 30))
                                    .foregroundColor(.yellow)
                            }
                            
                            Button(action: { swipeCard(direction: .left) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 30))
                                    .foregroundColor(.red)
                            }
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            
                            Button(action: handleSuperLike) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: { swipeCard(direction: .right) }) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.green)
                            }
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            
                            Button(action: {
                                if hasCards {
                                    showMessageSheet = true
                                    onMessageSheetChange?(true)
                                    onSelectMessageUser?(users[currentIndex])
                                }
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 25)
                    } else {
                        EmptyStateView()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        NavigationTitleView(settingsType: .options)
                    }
                }
                
                // Chat Sheet'i göster
                if showChatSheet, let user = selectedChatUser {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showChatSheet = false
                        }
                    
                    GeometryReader { geometry in
                        ChatSheetView(
                            user: user,
                            isPresented: $showChatSheet,
                            lastMessage: Binding(
                                get: { nil },
                                set: { _ in }
                            ),
                            messages: Binding(
                                get: { [] },
                                set: { _ in }
                            )
                        )
                        .frame(height: geometry.size.height * 0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom))
                    }
                    .ignoresSafeArea()
                    .zIndex(1)
                }
            }
        }
    }
    
    // Önceki karta geri dönüş için rewind fonksiyonu
    private func rewindCard() {
        // Eğer zaten ilk kartta değilsek, bir önceki karta geri dön
        if currentIndex > 0 {
            // Önce kart indeksini azalt
            currentIndex -= 1
            
            // Önce kartı sağ tarafa yerleştir ve hafifçe döndür
            cardOffset.width = 300
            cardRotation = 15
            
            // Sonra kartı merkeze getir
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cardOffset = .zero
                cardRotation = 0
                swipeState = .none
            }
        }
    }
    
    // Handle card swipe action
    private func handleSwipeEnd(_ value: DragGesture.Value) {
        let width = value.translation.width
        let height = value.translation.height
        let draggingRight = width > 0
        let shouldSwipe = abs(width) > 100
        
        if shouldSwipe {
            let factor = draggingRight ? 1 : -1
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardOffset.width = CGFloat(factor) * 500
                cardOffset.height = height
            }
            
            // Increment likes count and track matches
            if draggingRight {
                likes += 1
                matches.insert(users[currentIndex])
                onMatch?(users[currentIndex])
            } else {
                // Left swipe is not a like, but still counts as a like action for stats
                likes += 1
            }
            
            withAnimation(.easeInOut(duration: 0.1).delay(0.2)) {
                currentIndex += 1
                cardOffset = .zero
                cardRotation = 0
                swipeState = .none
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardOffset = .zero
                cardRotation = 0
                swipeState = .none
            }
        }
    }
    
    private enum SwipeDirection {
        case left, right
    }
    
    private func swipeCard(direction: SwipeDirection) {
        guard hasCards else { return }
        
        swipeState = direction == .right ? .like : .nope
        
        let factor = direction == .right ? 1 : -1
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cardOffset.width = CGFloat(factor) * 500
            cardOffset.height = 0
        }
        
        // Increment likes count and track matches
        if direction == .right {
            likes += 1
            matches.insert(users[currentIndex])
            onMatch?(users[currentIndex])
        } else {
            // Left swipe is not a like, but still counts as a like action for stats
            likes += 1
        }
        
        withAnimation(.easeInOut(duration: 0.1).delay(0.2)) {
            currentIndex += 1
            cardOffset = .zero
            cardRotation = 0
            swipeState = .none
        }
    }
    
    private func handleSuperLike() {
        guard hasCards else { return }
        
        swipeState = .superLike
        likes += 1
        matches.insert(users[currentIndex])
        onMatch?(users[currentIndex])
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cardOffset.width = 0
            cardOffset.height = -500
        }
        
        withAnimation(.easeInOut(duration: 0.1).delay(0.2)) {
            currentIndex += 1
            cardOffset = .zero
            cardRotation = 0
            swipeState = .none
        }
    }
}

// MARK: - Card Stack View
struct CardStackView: View {
    let users: [User]
    @Binding var currentIndex: Int
    @Binding var cardOffset: CGSize
    @Binding var cardRotation: Double
    @Binding var swipeState: SwipeState
    @Binding var matches: Set<User>
    let onMatch: ((User) -> Void)?
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    // Buton işlevleri için callback'ler
    var onRewind: (() -> Void)? = nil
    var onSwipeLeft: (() -> Void)? = nil
    var onSuperLike: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil
    var onMessage: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            ForEach(Array(users.enumerated().reversed()), id: \.element.id) { index, user in
                if index >= currentIndex && index <= currentIndex + 2 {
                    CardView(
                        user: user,
                        isTop: index == currentIndex,
                        cardPosition: CGFloat(index - currentIndex),
                        totalCards: users.count,
                        index: index,
                        cardOffset: cardOffset,
                        swipeState: swipeState,
                        onLike: {
                            matches.insert(user)
                            onMatch?(user)
                            updateCard()
                        },
                        onDragChanged: onDragChanged,
                        onDragEnded: onDragEnded,
                        onRewind: onRewind,
                        onSwipeLeft: onSwipeLeft,
                        onSuperLike: onSuperLike,
                        onSwipeRight: onSwipeRight,
                        onMessage: onMessage
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
    
    private func updateCard() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentIndex += 1
            cardOffset = .zero
            cardRotation = 0
            swipeState = .none
        }
    }
}

// MARK: - Individual Card View
private struct CardView: View {
    let user: User
    let isTop: Bool
    let cardPosition: CGFloat
    let totalCards: Int
    let index: Int
    let cardOffset: CGSize
    let swipeState: SwipeState
    let onLike: () -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    // Buton işlevleri için callback'ler
    var onRewind: (() -> Void)? = nil
    var onSwipeLeft: (() -> Void)? = nil
    var onSuperLike: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil
    var onMessage: (() -> Void)? = nil
    
    var body: some View {
        SwipeableCard(
            user: user,
            onRemove: { isLiked in
                if isLiked {
                    onLike()
                }
            },
            swipeState: isTop ? swipeState : .none,
            onRewind: onRewind,
            onSwipeLeft: onSwipeLeft,
            onSuperLike: onSuperLike,
            onSwipeRight: onSwipeRight,
            onMessage: onMessage
        )
        .modifier(CardModifier(
            isTop: isTop,
            cardPosition: cardPosition,
            cardOffset: cardOffset,
            totalCards: totalCards,
            index: index
        ))
        .gesture(isTop ? makeDragGesture() : nil)
    }
    
    private func makeDragGesture() -> some Gesture {
        DragGesture()
            .onChanged(onDragChanged)
            .onEnded(onDragEnded)
    }
}

// MARK: - Card Modifier
private struct CardModifier: ViewModifier {
    let isTop: Bool
    let cardPosition: CGFloat
    let cardOffset: CGSize
    let totalCards: Int
    let index: Int
    
    func body(content: Content) -> some View {
        content
            .offset(y: isTop ? 0 : -10 * cardPosition)
            .scaleEffect(isTop ? 1 : 1 - cardPosition * 0.05)
            .offset(
                x: isTop ? cardOffset.width : 0,
                y: isTop ? cardOffset.height : 0
            )
            .rotationEffect(.degrees(isTop ? Double(cardOffset.width / 10) : 0))
            .zIndex(Double(totalCards - index))
    }
}

#Preview {
    HomeScreen(
        matches: .constant(Set<User>()),
        likes: .constant(0),
        onMessageSheetChange: { _ in }
    )
} 
