import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    var selectedImage: (UIImage?) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
                parent.selectedImage(nil)
                return
            }
            
            // Use a more reliable method to load the image
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.parent.selectedImage(nil)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage {
                            // Normalize the image orientation
                            let normalizedImage = self?.normalizeImageOrientation(uiImage)
                            self?.parent.selectedImage(normalizedImage)
                        } else {
                            self?.parent.selectedImage(nil)
                        }
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                // Fallback to loading the data and creating an image from it
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            let normalizedImage = self?.normalizeImageOrientation(image)
                            self?.parent.selectedImage(normalizedImage)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.parent.selectedImage(nil)
                        }
                    }
                }
            }
        }
        
        // Helper function to fix image orientation
        private func normalizeImageOrientation(_ image: UIImage) -> UIImage {
            if image.imageOrientation == .up {
                return image
            }
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return normalizedImage ?? image
        }
    }
} 