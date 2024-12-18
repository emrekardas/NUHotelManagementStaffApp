import SwiftUI
import FirebaseFirestore

struct ServiceRequestsView: View {
    @StateObject private var viewModel = ServiceRequestViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.serviceRequests) { request in
                ServiceRequestCell(
                    request: request,
                    onStatusChange: { newStatus in
                        if let requestId = request.id {  // Optional ID kontrolü
                            viewModel.updateServiceStatus(requestId: requestId, status: newStatus)
                        }
                    }
                )
            }
            .navigationTitle("Service Requests")
            .onAppear {
                viewModel.fetchServiceRequests()
            }
        }
    }
}

struct ServiceRequestCell: View {
    let request: ServiceRequest
    let onStatusChange: (ServiceRequest.ServiceStatus) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(request.type.rawValue)
                    .font(.headline)
                Spacer()
                Menu {
                    ForEach(ServiceRequest.ServiceStatus.allCases, id: \.self) { status in
                        Button(status.rawValue) {
                            onStatusChange(status)
                        }
                    }
                } label: {
                    Text(request.status.rawValue)
                        .foregroundColor(Color(hex: request.status.hexColor))
                }
            }
            
            Text("Created: \(formatTimestamp(request.createdAt))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    // Timestamp'i formatlama fonksiyonu
    private func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Color extension'ı (eğer yoksa)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 