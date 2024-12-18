import Firebase
import FirebaseFirestore
import Foundation

struct Room: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let roomNumbers: [String]
    let type: String
    let capacity: Int
    let price: Int
    let size: String
    let view: String
    let hasBalcony: Bool
    let description: String
    let imageUrl: String
    let amenities: [String]
    let availability: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roomNumbers
        case type
        case capacity
        case price
        case size
        case view
        case hasBalcony
        case description
        case imageUrl
        case amenities
        case availability
    }
} 
