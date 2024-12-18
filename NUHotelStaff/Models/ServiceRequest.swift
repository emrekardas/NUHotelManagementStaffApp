import Foundation
import FirebaseFirestore

struct ServiceRequest: Identifiable, Codable {
    @DocumentID var id: String?
    let bookingId: String
    let type: ServiceType
    var status: ServiceStatus
    let createdAt: Timestamp
    
    enum ServiceType: String, Codable {
        case roomCleaning = "Room Cleaning"
        case maintenance = "Technical Support"
        case roomService = "Room Service"
        case extraBed = "Extra Bed"
        case extraTowels = "Extra Towels"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            
            switch rawValue {
            case "Extra Towels":
                self = .extraTowels
            case "Room Cleaning":
                self = .roomCleaning
            case "Technical Support":
                self = .maintenance
            case "Room Service":
                self = .roomService
            case "Extra Bed":
                self = .extraBed
            default:
                print("Unknown service type: \(rawValue)")
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown service type: \(rawValue)"
                )
            }
        }
    }
    
    enum ServiceStatus: String, Codable, CaseIterable {
        case pending = "Pending"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
        
        var hexColor: String {
            switch self {
            case .pending: return "#FFC107"    // Yellow
            case .inProgress: return "#2196F3"  // Blue
            case .completed: return "#4CAF50"   // Green
            case .cancelled: return "#F44336"   // Red
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookingId
        case type
        case status
        case createdAt
    }
} 
