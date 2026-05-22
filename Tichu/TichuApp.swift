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

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    appDelegate.onDeviceToken = { token in
                        NetworkService.shared.pendingDeviceToken = token
                        print("Saved device token")
                    }
                }
        }
    }
}
