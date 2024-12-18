import FirebaseFirestore
import Foundation

struct Booking: Codable, Identifiable {
    @DocumentID var id: String?
    let roomNumber: String
    let startDate: Timestamp
    let endDate: Timestamp
    let status: String
    let userId: String
    let roomId: String
    let numberOfGuests: Int
    let totalPrice: Double
    let specialRequests: String?
    let roomName: String
    let roomImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomNumber
        case startDate
        case endDate
        case status
        case userId
        case roomId
        case numberOfGuests
        case totalPrice
        case specialRequests
        case roomName
        case roomImageUrl
    }
} 