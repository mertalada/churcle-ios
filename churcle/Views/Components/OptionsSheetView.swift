import SwiftUI

struct OptionsSheetView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var distance = 50.0
    @State private var showOnlyVerified = false
    @State private var ageRange: ClosedRange<Double> = 18...50
    @State private var lookingForGender = "Kadın"
    @State private var showMe = "Erkek"
    @State private var selectedLookingFor: [String] = []
    @StateObject private var userProfile = UserProfile.shared
    
    let genderOptions = ["Kadın", "Erkek", "Hepsi"]
    let lookingForOptions = ["friends", "married", "relationship", "hanging out", "undecided"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                
                Text("Keşif Ayarları")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    // Distance
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Maksimum Mesafe")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                Text("\(Int(distance)) km")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            Slider(value: $distance, in: 2...100, step: 1)
                                .accentColor(.blue)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 10)
                        .background(Color.sheetBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Age Range with single slider
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Yaş Aralığı")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                Text("\(Int(ageRange.lowerBound)) - \(Int(ageRange.upperBound)) yaş")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Single range slider that can be dragged from both ends
                            RangeSlider(range: $ageRange, bounds: 18...65)
                                .frame(height: 30)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 10)
                        .background(Color.sheetBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Looking For section (moved from ProfileEditSheetView)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Looking for")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        FlowLayout(spacing: 10) {
                            ForEach(lookingForOptions, id: \.self) { option in
                                Button(action: {
                                    if selectedLookingFor.contains(option) {
                                        selectedLookingFor.removeAll { $0 == option }
                                    } else {
                                        selectedLookingFor.append(option)
                                    }
                                }) {
                                    Text(option)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(selectedLookingFor.contains(option) ? Color.red : Color.lightGrayButton)
                                        )
                                        .foregroundColor(selectedLookingFor.contains(option) ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.sheetBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Looking for gender section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Karşıma Çıkacak Kişiler")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            ForEach(genderOptions, id: \.self) { option in
                                Button(action: {
                                    lookingForGender = option
                                }) {
                                    HStack {
                                        Text(option)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if lookingForGender == option {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                }
                                
                                if option != genderOptions.last {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(Color.sheetBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Show me as section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Beni Göster")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            ForEach(genderOptions.prefix(2), id: \.self) { option in
                                Button(action: {
                                    showMe = option
                                }) {
                                    HStack {
                                        Text(option)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if showMe == option {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                }
                                
                                if option != genderOptions.prefix(2).last {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(Color.sheetBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Verified accounts toggle
                    VStack(alignment: .leading, spacing: 15) {
                        Toggle(isOn: $showOnlyVerified) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Sadece Onaylı Profiller")
                                    .fontWeight(.semibold)
                                
                                Text("Sadece kimlik onayı yapmış kullanıcıları göster")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding()
                        .background(Color.sheetBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Notification Settings
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                        
                        Text("BİLDİRİM AYARLARI")
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Notification toggles
                    VStack {
                        Toggle("Yeni Eşleşmeler", isOn: .constant(true))
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                        
                        Toggle("Mesajlar", isOn: .constant(true))
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                        
                        Toggle("Beğeniler", isOn: .constant(true))
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                    }
                    .background(Color.sheetBackground)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .background(Color.sheetBackground)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .onAppear {
            // Load user profile data
            selectedLookingFor = userProfile.lookingFor
        }
        .onDisappear {
            // Save data when view disappears
            userProfile.lookingFor = selectedLookingFor
        }
    }
}

// Custom RangeSlider for age range
struct RangeSlider: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    @State private var lowerHandlePosition: CGFloat = 0
    @State private var upperHandlePosition: CGFloat = 0
    @State private var isDraggingLower = false
    @State private var isDraggingUpper = false
    
    private let trackHeight: CGFloat = 6
    private let handleDiameter: CGFloat = 28
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trackHeight)
                    .cornerRadius(trackHeight / 2)
                
                // Active track
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: upperHandlePosition - lowerHandlePosition, height: trackHeight)
                    .offset(x: lowerHandlePosition)
                    .cornerRadius(trackHeight / 2)
                
                // Lower handle
                Circle()
                    .fill(Color.white)
                    .frame(width: handleDiameter, height: handleDiameter)
                    .offset(x: lowerHandlePosition - handleDiameter / 2)
                    .shadow(radius: 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingLower = true
                                let newPosition = min(
                                    upperHandlePosition - handleDiameter / 2,
                                    max(0, value.location.x)
                                )
                                lowerHandlePosition = newPosition
                                
                                // Update the range value
                                let lowerBound = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * (newPosition / geometry.size.width)
                                range = lowerBound...range.upperBound
                            }
                            .onEnded { _ in
                                isDraggingLower = false
                            }
                    )
                
                // Upper handle
                Circle()
                    .fill(Color.white)
                    .frame(width: handleDiameter, height: handleDiameter)
                    .offset(x: upperHandlePosition - handleDiameter / 2)
                    .shadow(radius: 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingUpper = true
                                let newPosition = max(
                                    lowerHandlePosition + handleDiameter / 2,
                                    min(geometry.size.width, value.location.x)
                                )
                                upperHandlePosition = newPosition
                                
                                // Update the range value
                                let upperBound = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * (newPosition / geometry.size.width)
                                range = range.lowerBound...upperBound
                            }
                            .onEnded { _ in
                                isDraggingUpper = false
                            }
                    )
            }
            .onAppear {
                // Initialize handle positions based on range values
                let width = geometry.size.width
                let lowerPercent = (range.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
                let upperPercent = (range.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
                lowerHandlePosition = width * CGFloat(lowerPercent)
                upperHandlePosition = width * CGFloat(upperPercent)
            }
            .onChange(of: range) { _, newRange in
                // Update handle positions when range changes externally
                let width = geometry.size.width
                let lowerPercent = (newRange.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
                let upperPercent = (newRange.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
                
                if !isDraggingLower {
                    lowerHandlePosition = width * CGFloat(lowerPercent)
                }
                
                if !isDraggingUpper {
                    upperHandlePosition = width * CGFloat(upperPercent)
                }
            }
        }
    }
}

#Preview {
    let themeManager = ThemeManager()
    return OptionsSheetView()
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
} 