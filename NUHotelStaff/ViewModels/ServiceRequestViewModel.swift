import SwiftUI
import FirebaseFirestore

class ServiceRequestViewModel: ObservableObject {
    @Published var serviceRequests: [ServiceRequest] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    func fetchServiceRequests() {
        isLoading = true
        print("Fetching service requests...")
        
        db.collection("serviceRequests")
            .order(by: "createdAt", descending: true) // En yeni istekler üstte
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching service requests: \(error.localizedDescription)")
                    self.error = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                print("Number of documents in snapshot: \(snapshot?.documents.count ?? 0)")
                
                var requests: [ServiceRequest] = []
                
                snapshot?.documents.forEach { document in
                    print("\nProcessing document ID: \(document.documentID)")
                    print("Document data: \(document.data())")
                    
                    if let request = try? document.data(as: ServiceRequest.self) {
                        print("Successfully decoded request: \(request.type.rawValue)")
                        requests.append(request)
                    } else {
                        print("Failed to decode document: \(document.documentID)")
                        if let type = document.data()["type"] as? String {
                            print("Type in document: \(type)")
                        }
                    }
                }
                
                print("\nTotal decoded requests: \(requests.count)")
                self.serviceRequests = requests
                self.isLoading = false
            }
    }
    
    func updateServiceStatus(requestId: String, status: ServiceRequest.ServiceStatus) {
        print("Updating status for request: \(requestId) to \(status.rawValue)")
        
        db.collection("serviceRequests").document(requestId).updateData([
            "status": status.rawValue,
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error updating service status: \(error.localizedDescription)")
            } else {
                print("Successfully updated status")
            }
        }
    }
} 