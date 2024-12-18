//
//  ContentView.swift
//  NUHotelStaff
//
//  Created by Emre on 18/12/2024.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authService = StaffAuthService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView {
                    NavigationView {
                        RoomsView()
                            .navigationTitle("Rooms")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        Task {
                                            try? await authService.signOut()
                                        }
                                    }) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                    }
                    .tabItem {
                        Image(systemName: "bed.double.fill")
                        Text("Rooms")
                    }
                    
                    NavigationView {
                        ServiceRequestsView()
                            .navigationTitle("Services")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        Task {
                                            try? await authService.signOut()
                                        }
                                    }) {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                    }
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Services")
                    }
                }
            } else {
                StaffLoginView(authService: authService)
            }
        }
        .alert("Error", isPresented: .constant(authService.authError != nil)) {
            Button("OK", role: .cancel) {
                authService.authError = nil
            }
        } message: {
            if let error = authService.authError {
                Text(error)
            }
        }
    }
}

struct StaffLoginView: View {
    @ObservedObject var authService: StaffAuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("NU Hotel Staff")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disabled(isLoading)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(isLoading)
            
            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .disabled(isLoading)
        }
        .padding()
    }
    
    private func signIn() {
        isLoading = true
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
