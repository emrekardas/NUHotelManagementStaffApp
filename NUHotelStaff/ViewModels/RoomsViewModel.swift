import Foundation
import FirebaseFirestore

class RoomsViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var isLoading = false
    @Published var occupiedRoomNumbers: Set<String> = []
    
    private let db = Firestore.firestore()
    
    func fetchRooms() {
        isLoading = true
        
        // Önce odaları getir
        db.collection("rooms").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching rooms: \(error)")
                return
            }
            
            self.rooms = snapshot?.documents.compactMap { document in
                try? document.data(as: Room.self)
            } ?? []
            
            // Sonra aktif rezervasyonları kontrol et
            self.checkOccupiedRooms()
        }
    }
    
    private func checkOccupiedRooms() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        print("Checking occupied rooms at: \(formatter.string(from: now))")
        
        db.collection("bookings")
            .whereField("status", isEqualTo: "confirmed")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching bookings: \(error)")
                    return
                }
                
                var occupiedRooms = Set<String>()
                
                snapshot?.documents.forEach { document in
                    if let booking = try? document.data(as: Booking.self) {
                        let startDate = booking.startDate.dateValue()
                        let endDate = booking.endDate.dateValue()
                        
                        print("\n=== Booking Details for room \(booking.roomNumber) ===")
                        print("Start Date: \(formatter.string(from: startDate))")
                        print("End Date: \(formatter.string(from: endDate))")
                        print("Current Date: \(formatter.string(from: now))")
                        
                        // Tarih karşılaştırmalarını ayrı ayrı yapalım
                        let isAfterStart = startDate <= now
                        let isBeforeEnd = endDate >= now
                        
                        print("Is after start date: \(isAfterStart)")
                        print("Is before end date: \(isBeforeEnd)")
                        print("Final occupation check: \(isAfterStart && isBeforeEnd)")
                        
                        if isAfterStart && isBeforeEnd {
                            occupiedRooms.insert(booking.roomNumber)
                            print("Added \(booking.roomNumber) to occupied rooms")
                        }
                        print("=====================================\n")
                    } else {
                        print("Failed to parse booking document: \(document.data())")
                    }
                }
                
                print("Final occupied rooms: \(occupiedRooms)")
                self.occupiedRoomNumbers = occupiedRooms
                self.isLoading = false
                
                // Tüm odaların durumunu yazdıralım
                self.rooms.forEach { room in
                    room.roomNumbers.forEach { number in
                        print("Room \(number) final occupation status: \(self.isRoomOccupied(number))")
                    }
                }
            }
    }
    
    func isRoomOccupied(_ roomNumber: String) -> Bool {
        return occupiedRoomNumbers.contains(roomNumber)
    }
} 
