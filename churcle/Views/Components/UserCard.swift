import SwiftUI

struct UserCard: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Profile Image
            Image("placeholder_profile")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height * 0.7)
                .cornerRadius(10)
            
            // User Info Overlay
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Duru, 22")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.white)
                    Text("8 km uzakta")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
        .shadow(radius: 5)
    }
}

#Preview {
    UserCard()
        .padding()
} 