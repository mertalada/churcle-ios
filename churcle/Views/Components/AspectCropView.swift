import SwiftUI
import UIKit

struct AspectCropView: View {
    let sourceImage: UIImage
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void
    
    // Fixed dimensions for crop area
    private let cropWidth: CGFloat = 250
    private let cropHeight: CGFloat = 550
    
    // State for dragging the crop frame
    @State private var cropFramePosition = CGPoint(x: 0, y: 0)
    @State private var dragStartPosition = CGPoint(x: 0, y: 0)
    
    // Calculate the scaled image size to fit the screen
    private var scaledImageSize: CGSize {
        let screenSize = UIScreen.main.bounds.size
        let widthRatio = screenSize.width / sourceImage.size.width
        let heightRatio = screenSize.height / sourceImage.size.height
        
        // Use a slightly larger ratio to ensure the image fills more of the screen
        let scaleFactor = min(widthRatio, heightRatio) * 1.2
        
        return CGSize(
            width: sourceImage.size.width * scaleFactor,
            height: sourceImage.size.height * scaleFactor
        )
    }
    
    // Make sure we have a valid image
    init(sourceImage: UIImage, onCrop: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        // Ensure we have a proper image by drawing it into a new context
        let size = sourceImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, sourceImage.scale)
        sourceImage.draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? sourceImage
        UIGraphicsEndImageContext()
        
        self.sourceImage = normalizedImage
        self.onCrop = onCrop
        self.onCancel = onCancel
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Main content
                    ZStack {
                        // Full image with blur outside crop area
                        Image(uiImage: sourceImage)
                            .resizable()
                            .scaledToFit()
                            .blur(radius: 10)
                            .frame(width: scaledImageSize.width, height: scaledImageSize.height)
                        
                        // Crop area overlay with mask
                        ZStack {
                            // Semi-transparent dark overlay
                            Rectangle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: scaledImageSize.width, height: scaledImageSize.height)
                            
                            // Cutout for crop area (no border)
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: cropWidth, height: cropHeight)
                                .offset(x: cropFramePosition.x, y: cropFramePosition.y)
                        }
                        
                        // Clear image inside crop area
                        Image(uiImage: sourceImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: scaledImageSize.width, height: scaledImageSize.height)
                            .mask(
                                Rectangle()
                                    .frame(width: cropWidth, height: cropHeight)
                                    .offset(x: cropFramePosition.x, y: cropFramePosition.y)
                            )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.85)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newX = dragStartPosition.x + value.translation.width
                                let newY = dragStartPosition.y + value.translation.height
                                
                                // Calculate boundaries to keep crop frame within image
                                let maxX = (scaledImageSize.width - cropWidth) / 2
                                let maxY = (scaledImageSize.height - cropHeight) / 2
                                
                                // Ensure crop frame stays within image boundaries
                                cropFramePosition = CGPoint(
                                    x: min(maxX, max(-maxX, newX)),
                                    y: min(maxY, max(-maxY, newY))
                                )
                            }
                            .onEnded { _ in
                                // Save the final position for next drag
                                dragStartPosition = cropFramePosition
                            }
                    )
                    
                    Spacer()
                    
                    // Bottom buttons
                    HStack {
                        Button(action: onCancel) {
                            Text("İptal")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 120, height: 44)
                                .background(Color.red.opacity(0.6))
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            let croppedImage = cropImage()
                            onCrop(croppedImage)
                        }) {
                            Text("Uygula")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 120, height: 44)
                                .background(Color.blue.opacity(0.6))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    // Crop function
    private func cropImage() -> UIImage {
        // Calculate the crop region in the original image coordinates
        let widthRatio = sourceImage.size.width / scaledImageSize.width
        let heightRatio = sourceImage.size.height / scaledImageSize.height
        
        // Calculate the center of the image
        let imageCenterX = scaledImageSize.width / 2
        let imageCenterY = scaledImageSize.height / 2
        
        // Calculate crop region in scaled coordinates
        let cropX = imageCenterX + cropFramePosition.x - cropWidth / 2
        let cropY = imageCenterY + cropFramePosition.y - cropHeight / 2
        
        // Convert to original image coordinates
        let originX = cropX * widthRatio
        let originY = cropY * heightRatio
        let width = cropWidth * widthRatio
        let height = cropHeight * heightRatio
        
        // Create the crop rectangle in the original image coordinates
        let cropRect = CGRect(
            x: originX,
            y: originY,
            width: width,
            height: height
        )
        
        // Make sure we crop within the image bounds
        let safeCropRect = cropRect.intersection(CGRect(origin: .zero, size: sourceImage.size))
        
        // Perform the crop
        if let cgImage = sourceImage.cgImage,
           let croppedCGImage = cgImage.cropping(to: safeCropRect) {
            return UIImage(cgImage: croppedCGImage)
        }
        
        // Return original if crop failed
        return sourceImage
    }
}

// Overlay for the crop area
struct CropOverlay: View {
    let cropWidth: CGFloat
    let cropHeight: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.5))
            .edgesIgnoringSafeArea(.all)
            .overlay(
                Rectangle()
                    .frame(width: cropWidth, height: cropHeight)
                    .blendMode(.destinationOut)
            )
            .compositingGroup()
            .overlay(
                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: cropWidth, height: cropHeight)
            )
    }
} 