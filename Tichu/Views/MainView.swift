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
    @State private var isLoading: Bool = false
    @State private var fetchTrigger: Int = 0
    @State private var selectedGameId: Int? = nil
    @State private var scrolledGameId: Int? = nil
    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared
    let notificationCenter = UNUserNotificationCenter.current()

    private var isDisconnected: Binding<Bool> {
        .constant(!socket.connected)
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
                    //PlayView(fetchTrigger: fetchTrigger)
                    PlayView()
                        .tabItem {
                            Label("Play", systemImage: "play")
                        }
                        .tag(0)
                    
                    
                    if socket.connected {
                        HistoryView(selectedGameId:$selectedGameId,scrolledGameId: $scrolledGameId).tabItem {
                            Label("History", systemImage: "clock")
                        }
                        .tag(1)
                    } else {
                        OfflineView(showNavBar: .constant(true)).tabItem {
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
                    }else{
                        OfflineView(showNavBar: .constant(true)).tabItem {
                            Label("History", systemImage: "clock")
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
                .onAppear() {
                    Task {
                        await network.fetch()
                    }
                }
                .onAppear {
                    selectedTab = 0
                }
                .alert(isPresented: isDisconnected) {
                    OfflineView.offlineAlert()
                }
                .task {
                    do {
                        try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
                    } catch {
                        print("Request authorization error")
                    }
                }
            }
        }.onOpenURL { url in
            if url == URL(string: "tichu://elo"){
                selectedTab = 1
            }
            if url == URL(string: "tichu://stats"){
                selectedTab = 2
            }
            if url.scheme == "tichu",
                   url.host == "game" {
                    
                    // extract game id from path
                    let gameId = url.lastPathComponent
                    
                    
                    selectedTab = 1
                    selectedGameId = Int(gameId)
                    scrolledGameId = Int(gameId)
                    
                  
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didTapPushNotification)) { _ in
            selectedTab = 3
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .openFriendsSheet, object: nil)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: userId == -69420)
    }
}

#Preview {
    MainView()
}
