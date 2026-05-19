//
//  TichuApp.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

@main
struct TichuApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: CustomAppDelegate
    @AppStorage("userId") private var userId = -69420

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    appDelegate.onDeviceToken = { token in
                        NetworkService.shared.pendingDeviceToken = token
                        guard userId != -69420 else {
                            print("Token saved but user not logged in yet")
                            return
                        }
                        Task {
                            await NetworkService.shared.registerDevice(profileId: userId, deviceToken: token)
                        }
                    }
                }
                .onChange(of: userId) {
                    guard userId != -69420 else { return }
                    let token = NetworkService.shared.pendingDeviceToken
                    guard !token.isEmpty else {
                        print("No pending token to register")
                        return
                    }
                    Task {
                        print("User logged in, registering token")
                        await NetworkService.shared.registerDevice(profileId: userId, deviceToken: token)
                    }
                }
        }
    }
}
