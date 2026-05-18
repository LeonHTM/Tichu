//
//  MainView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI
import UserNotifications



struct MainView: View {
    
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage("userId") private var userId = -69420
    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared
    let notificationCenter = UNUserNotificationCenter.current()
    private var isDisconnected: Binding<Bool> {
        Binding(
            get: { !socket.connected },
            set: { _ in }
        )
    }
    
    var body: some View {
        if userId == -69420{
           
                LoginMainView()
            
        }else{
            TabView(selection: $selectedTab) {
                
                PlayView()
                    .tabItem {
                        Label("Play", systemImage: "play")
                    }
                    .tag(0)
                if socket.connected{
                    HistoryView().tabItem {
                        Label("History", systemImage: "clock")
                    }
                    .tag(1)
                }else{
                    offlineView().tabItem {
                        Label("History", systemImage: "clock")
                    }
                    .tag(1)
                }
                    
                if socket.connected{
                    StatsView()
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar")
                        }
                        .tag(2)
                }else {
                    offlineView().tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }
                    .tag(2)
                }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(3)
            }.task {
                await network.fetchProfiles()
                await network.fetchFriends(profileId:userId)
                await network.fetchFriendRequests(profileId:userId)
            }.onAppear{
                selectedTab = 0
            }.alert(isPresented: isDisconnected) {
                offlineView.offlineAlert()
            }.task{
                do {
                    try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
                } catch {
                    print("Request authorization error")
                }
            }
        }
    }
}

#Preview {
    MainView()
}

