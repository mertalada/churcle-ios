import Foundation
import SwiftUI

struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let age: Int
    let image: String
    let bio: String
    let distance: Int
    
    static var sampleUsers: [User] = [
        User(name: "Ayşe", age: 24, image: "profile1", bio: "Hayat dolu ve maceracı", distance: 5),
        User(name: "Zeynep", age: 23, image: "profile2", bio: "Sanat ve müzik tutkunu", distance: 3),
        User(name: "Elif", age: 25, image: "profile3", bio: "Seyahat etmeyi seven bir ruh", distance: 7),
        User(name: "Selin", age: 22, image: "profile4", bio: "Spor ve doğa aşığı", distance: 2),
        User(name: "Deniz", age: 26, image: "profile5", bio: "Kitap kurdu ve film eleştirmeni", distance: 4)
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

class UserProfile: ObservableObject {
    static let shared = UserProfile()
    
    @Published var name: String = "Mert"
    @Published var age: Int = 25
    @Published var bio: String = "Hayatı keşfetmeye ve her anını dolu dolu yaşamaya inanıyorum."
    @Published var distance: Int = 5
    @Published var photos: [PhotoItem] = []
    @Published var education: String = "Üniversite Mezunları"
    @Published var school: String = "İstanbul Üniversitesi"
    @Published var workplace: String = "Yazılım Şirketi"
    @Published var horoscope: String = "Boğa"
    @Published var interests: [String] = ["Spor", "Müzik", "Seyahat"]
    @Published var lookingFor: [String] = ["friends"]
    @Published var city: String = "İstanbul"
    
    private init() {
        // Initialize with default profile photo
        if let profileImage = UIImage(named: "profile") {
            photos = [
                PhotoItem(image: profileImage),
                PhotoItem(image: profileImage)
            ]
        }
    }
    
    func calculateProfileCompletion() -> Int {
        var totalPoints = 0
        let _ = 100
        
        // Photos - 25 points (scaled by how many photos out of 9)
        let photoPoints = min(25, Int((Double(photos.count) / 9.0) * 25))
        totalPoints += photoPoints
        
        // Bio - 15 points (need at least 50 characters for full points)
        if bio.count >= 50 {
            totalPoints += 15
        } else if !bio.isEmpty {
            // Partial points for having some bio
            totalPoints += Int((Double(bio.count) / 50.0) * 15)
        }
        
        // School - 10 points
        if !school.isEmpty {
            totalPoints += 10
        }
        
        // Education - 10 points
        if !education.isEmpty {
            totalPoints += 10
        }
        
        // Horoscope - 10 points
        if !horoscope.isEmpty {
            totalPoints += 10
        }
        
        // Workplace - 10 points
        if !workplace.isEmpty {
            totalPoints += 10
        }
        
        // Interests - 15 points (need at least 4 interests for full points)
        if interests.count >= 4 {
            totalPoints += 15
        } else if !interests.isEmpty {
            // Partial points for having some interests
            totalPoints += Int((Double(interests.count) / 4.0) * 15)
        }
        
        // City - 5 points
        if !city.isEmpty {
            totalPoints += 5
        }
        
        return totalPoints
    }
} 