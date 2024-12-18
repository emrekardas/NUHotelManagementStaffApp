//
//  NUHotelStaffApp.swift
//  NUHotelStaff
//
//  Created by Emre on 18/12/2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct NUHotelStaffApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = StaffAuthService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                ContentView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
