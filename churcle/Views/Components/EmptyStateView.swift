import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "location.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Profil Bulunamadı")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Mesafeyi genişletin")
                .font(.title3)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    EmptyStateView()
} 