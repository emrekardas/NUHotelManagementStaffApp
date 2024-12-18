import Foundation
import FirebaseAuth

struct StaffUser: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let displayName: String
    let role: String
    let department: String
    let createdAt: Date
    let updatedAt: Date
    
    var isStaff: Bool {
        return role == "staff" || role == "admin"
    }
    
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.firstName = firebaseUser.displayName?.components(separatedBy: " ").first ?? ""
        self.lastName = firebaseUser.displayName?.components(separatedBy: " ").last ?? ""
        self.displayName = firebaseUser.displayName ?? ""
        self.role = "staff"
        self.department = "general"
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init(id: String,
         email: String,
         firstName: String,
         lastName: String,
         displayName: String,
         role: String,
         department: String,
         createdAt: Date,
         updatedAt: Date) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
        self.role = role
        self.department = department
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
} 