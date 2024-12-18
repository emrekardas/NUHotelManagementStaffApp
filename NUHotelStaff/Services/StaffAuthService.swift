import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class StaffAuthService: ObservableObject {
    @Published var currentUser: StaffUser?
    @Published var isAuthenticated = false
    @Published var authError: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                Task {
                    await self?.fetchUserData(userId: user.uid)
                }
            } else {
                DispatchQueue.main.async {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            print("Attempting to sign in with email: \(email)")
            
            let result = try await auth.signIn(withEmail: email, password: password)
            print("Successfully signed in with UID: \(result.user.uid)")
            
            await fetchUserData(userId: result.user.uid)
        } catch {
            print("Sign in error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.authError = error.localizedDescription
            }
            throw error
        }
    }
    
    private func fetchUserData(userId: String) async {
        do {
            print("Fetching user data for UID: \(userId)")
            
            let docRef = db.collection("users").document(userId)
            let document = try await docRef.getDocument()
            
            guard let data = document.data() else {
                print("No document found for user")
                DispatchQueue.main.async {
                    self.authError = "User data not found"
                }
                return
            }
            
            print("Found user data: \(data)")
            
            guard let role = data["role"] as? String,
                  (role == "staff" || role == "admin") else {
                print("User is not staff member")
                try? await signOut()
                DispatchQueue.main.async {
                    self.authError = "Unauthorized access. Staff only."
                }
                return
            }
            
            let user = StaffUser(
                id: data["id"] as? String ?? "",
                email: data["email"] as? String ?? "",
                firstName: data["firstName"] as? String ?? "",
                lastName: data["lastName"] as? String ?? "",
                displayName: data["displayName"] as? String ?? "",
                role: role,
                department: data["department"] as? String ?? "general",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            print("Successfully created StaffUser object")
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.authError = nil
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.authError = error.localizedDescription
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
    
    func signOut() async throws {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
                self.authError = nil
            }
        } catch {
            throw error
        }
    }
} 