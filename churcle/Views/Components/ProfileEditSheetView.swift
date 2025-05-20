import SwiftUI
import PhotosUI
import UIKit

// Using UIKit image picker directly (simpler approach)
struct DirectImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onSelectImage: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = context.coordinator
            controller.present(picker, animated: true)
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: DirectImagePicker
        
        init(_ parent: DirectImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true) {
                self.parent.isPresented = false
                
                if let image = info[.originalImage] as? UIImage {
                    // Process image to avoid file system access issues
                    let size = CGSize(width: image.size.width, height: image.size.height)
                    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
                    image.draw(in: CGRect(origin: .zero, size: size))
                    let processedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let finalImage = processedImage {
                        DispatchQueue.main.async {
                            self.parent.onSelectImage(finalImage)
                        }
                    }
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                self.parent.isPresented = false
            }
        }
    }
}

struct ProfileEditSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var userProfile = UserProfile.shared
    
    // Main state
    @State private var smartPhotosEnabled = false
    @State private var bio = "Kendini ortaya koymaktan çekinme. Özgün olmak cazibelidir."
    @State private var selectedEducation = "Üniversite Mezunları"
    @State private var selectedZodiac = "Koç"
    @State private var selectedInterests = ["Spor", "Müzik"]
    @State private var selectedLookingFor: [String] = []
    @State private var cityText = "İstanbul"
    @State private var schoolText = "İstanbul Üniversitesi"
    @State private var workplaceText = ""
    @State private var selectedPickerIndex: Int?
    @State private var draggingItem: PhotoItem?
    
    // Image handling state
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingCrop = false
    
    let interestOptions = ["Spor", "Müzik", "Seyahat", "Yemek", "Sinema", "Kitap", "Sanat", "Dans", "Fotoğrafçılık", "Doğa", "Teknoloji", "Oyun"]
    let lookingForOptions = ["friends", "married", "relationship", "hanging out", "undecided"]
    
    var body: some View {
        ZStack {
            // Main content
            mainContent
            
            // Overlay the crop view when active
            if showingCrop, let image = selectedImage {
                cropView(for: image)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .onChange(of: showingImagePicker) { _, isShowing in
            // Reset if picker is dismissed without selection
            if !isShowing && selectedImage == nil {
                showingCrop = false
            }
        }
    }
    
    // Main content view
    var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Vazgeç")
                        .font(.body)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Düzenle")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action: {
                    // Save changes
                    userProfile.city = cityText
                    userProfile.school = schoolText
                    userProfile.education = selectedEducation
                    userProfile.lookingFor = selectedLookingFor
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Bitti")
                        .font(.body)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 15)
            .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                Spacer()
                Spacer()
                VStack(spacing: 20) {
                    // Media section
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        
                        Text("MEDYA")
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Photo grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(Array(userProfile.photos.enumerated()), id: \.element.id) { index, photo in
                            ZStack {
                                PhotoCell(image: photo.image)
                                    .overlay(
                                        Button(action: {
                                            userProfile.photos.remove(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.system(size: 24))
                                                .padding(5)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        .padding(5),
                                        alignment: .bottomTrailing
                                    )
                                    .onDrag {
                                        self.draggingItem = photo
                                        return NSItemProvider(object: "\(photo.id)" as NSString)
                                    }
                                    .onDrop(of: [.text], delegate: PhotoDropDelegate(destinationItem: photo, photoItems: $userProfile.photos, draggingItem: $draggingItem))
                            }
                            .frame(height: 150)
                        }
                        
                        // Empty cells for adding photos
                        ForEach(0..<(9 - userProfile.photos.count), id: \.self) { index in
                            Button(action: {
                                selectedPickerIndex = userProfile.photos.count + index
                                selectedImage = nil // Clear any previously selected image
                                showingImagePicker = true
                            }) {
                                PhotoPlaceholderCell()
                            }
                            .frame(height: 150)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Photo options
                    VStack(alignment: .leading, spacing: 15) {
                        Text("FOTOĞRAF AYARLARI")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Toggle(isOn: $smartPhotosEnabled) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Akıllı Fotoğraflar")
                                    .fontWeight(.semibold)
                                
                                Text("Akıllı Fotoğraflar, profil fotoğraflarını sürekli test ederek ilk görünmeye en uygun olanı seçer.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .onChange(of: smartPhotosEnabled) { _, newValue in
                            if newValue && userProfile.photos.count > 1 {
                                shufflePhotos()
                            }
                        }
                    }
                    
                    // Bio section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Hakkında")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextEditor(text: $userProfile.bio)
                            .scrollContentBackground(.hidden) // İçeriğin arka planını gizle     // Dış çerçeve arka planı
                            .foregroundColor(.black)  
                            .padding() 
                        .background(Color(.systemBackground))
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .frame(minHeight: 100)
                    }

                     // Looking For section
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
                                                .fill(selectedLookingFor.contains(option) ? Color.red : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedLookingFor.contains(option) ? .white : Color.black.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // City section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Yaşadığın Şehir")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextField("Şehir", text: $cityText)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }
                    
                    // School section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Okuduğun Okul")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextField("Okul", text: $schoolText)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }

                    // Work section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Çalıştığın yer")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextField("Mesleğini veya şirketini yaz", text: $workplaceText)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }
                    
                    // Education and Zodiac sections in 2 columns
                    VStack(spacing: 25) {
                        // Education section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Eğitim seviyen nedir?")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // Education options - now in a wrapped grid
                            FlowLayout(spacing: 10) {
                                ForEach(["Üniversite Mezunları", "Lisans Öğrencisi", "Lise", "Doktora", "Yüksek Lisans Öğrencisi", "Yüksek Lisans Mezunu", "Teknik Okul"], id: \.self) { education in
                                    Button(action: {
                                        selectedEducation = education
                                    }) {
                                        Text(education)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 10)
                                            .background(selectedEducation == education ? Color.red : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedEducation == education ? .white : Color.black.opacity(0.7))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Zodiac sign section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Burcun nedir?")
                                    .font(.headline)
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.gray)    
                            }
                            .padding(.horizontal)
                            
                            // Zodiac options - now in a wrapped grid
                            FlowLayout(spacing: 10) {
                                ForEach(["Oğlak", "Kova", "Balık", "Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak", "Terazi", "Akrep", "Yay"], id: \.self) { sign in
                                    Button(action: {
                                        selectedZodiac = sign
                                    }) {
                                        Text(sign)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 10)
                                            .background(selectedZodiac == sign ? Color.red : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedZodiac == sign ? .white : Color.black.opacity(0.7))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                  
                    // Interests section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("İlgi Alanları")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        FlowLayout(spacing: 10) {
                            ForEach(interestOptions, id: \.self) { interest in
                                Button(action: {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.removeAll { $0 == interest }
                                    } else {
                                        selectedInterests.append(interest)
                                    }
                                }) {
                                    Text(interest)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(selectedInterests.contains(interest) ? Color.red : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedInterests.contains(interest) ? .white : Color.black.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30) // Alt kısımda ekstra boşluk bırakma
                    }
                }
            }
        }
        .overlay(
            Group {
                if showingImagePicker {
                    DirectImagePicker(
                        isPresented: $showingImagePicker,
                        onSelectImage: { selectedImage in
                            self.selectedImage = selectedImage
                            self.showingCrop = true
                        }
                    )
                    .allowsHitTesting(false)
                    .frame(width: 0, height: 0)
                }
            }
        )
    }
    
    // Crop view
    func cropView(for image: UIImage) -> some View {
        AspectCropView(
            sourceImage: image,
            onCrop: { croppedImage in
                if let index = selectedPickerIndex {
                    let newPhotoItem = PhotoItem(image: croppedImage)
                    
                    if index < userProfile.photos.count {
                        userProfile.photos[index] = newPhotoItem
                    } else {
                        userProfile.photos.append(newPhotoItem)
                    }
                }
                showingCrop = false
                selectedImage = nil
            },
            onCancel: {
                showingCrop = false
                selectedImage = nil
            }
        )
        .zIndex(100) // Ensure it's above everything else
    }
    
    // Shuffle photos when smart photos is enabled
    private func shufflePhotos() {
        if userProfile.photos.count > 1 {
            let firstPhoto = userProfile.photos[0]
            userProfile.photos.remove(at: 0)
            userProfile.photos.shuffle()
            userProfile.photos.insert(firstPhoto, at: 0)
        }
    }
}

#Preview {
    ProfileEditSheetView()
} 