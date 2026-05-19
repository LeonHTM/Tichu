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
        Group {
            if userId == -69420 {
                LoginMainView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                TabView(selection: $selectedTab) {
                    PlayView()
                        .tabItem {
                            Label("Play", systemImage: "play")
                        }
                        .tag(0)

                    if socket.connected {
                        HistoryView().tabItem {
                            Label("History", systemImage: "clock")
                        }
                        .tag(1)
                    } else {
                        offlineView().tabItem {
                            Label("History", systemImage: "clock")
                        }
                        .tag(1)
                    }
                        
                    if socket.connected {
                        StatsView()
                            .tabItem {
                                Label("Stats", systemImage: "chart.bar")
                            }
                            .tag(2)
                    } else {
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
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .task {
                    await network.fetchProfiles()
                    await network.fetchFriends(profileId: userId)
                    await network.fetchFriendRequests(profileId: userId)
                }
                .onAppear {
                    if !(selectedTab == -1) {
                        selectedTab = 0
                    } else {
                        selectedTab = 3
                    }
                }
                .alert(isPresented: isDisconnected) {
                    offlineView.offlineAlert()
                }
                .task {
                    do {
                        try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
                    } catch {
                        print("Request authorization error")
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: userId == -69420)
    }
}

#Preview {
    MainView()
}
