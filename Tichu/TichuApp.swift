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
                        guard userId != -69420 else {
                            print("Could not sen token cause id == -69420")
                                  return }
                        Task {
                            await NetworkService.shared.registerDevice(profileId: userId, deviceToken: token)
                        }
                    }
                }.onChange(of:userId){
                    appDelegate.onDeviceToken = { token in
                        guard userId != -69420 else {
                            print("Could not sen token cause id == -69420 - onChange")
                            return
                        }
                        Task {
                            await NetworkService.shared.registerDevice(profileId: userId, deviceToken: token)
                        }
                    }
                }
        }
    }
}
