import SwiftUI
import FirebaseFirestore

struct RoomsView: View {
    @StateObject private var viewModel = RoomsViewModel()
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.rooms) { room in
                        ForEach(room.roomNumbers, id: \.self) { number in
                            RoomNumberCell(
                                roomNumber: number,
                                roomType: room.type,
                                viewModel: viewModel
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Odalar")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .onAppear {
                viewModel.fetchRooms()
            }
        }
    }
}

struct RoomNumberCell: View {
    let roomNumber: String
    let roomType: String
    @ObservedObject var viewModel: RoomsViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text(roomNumber)
                .font(.title2)
                .bold()
            
            Text(roomType)
                .font(.caption)
                .foregroundColor(.gray)
            
            Circle()
                .fill(viewModel.isRoomOccupied(roomNumber) ? Color.red : Color.green)
                .frame(width: 12, height: 12)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .onAppear {
            print("Room \(roomNumber) is occupied: \(viewModel.isRoomOccupied(roomNumber))")
        }
    }
} 