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
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isLoading: Bool = false
    @State private var fetchTrigger: Int = 0
    @State private var selectedGameId: Int? = nil
    @State private var scrolledGameId: Int? = nil
    @State private var sheetGame: Game? = nil
    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared
    let notificationCenter = UNUserNotificationCenter.current()

    private var isDisconnected: Binding<Bool> {
        .constant(!network.isOnline)
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
                    Tab(String(localized: "general.tabs.play"), systemImage: "play", value: 0) {
                        if network.isOnline {
                            PlayView()
                        }else {
                            OfflineView(showNavBar: .constant(true),title:"general.title.play")
                        }
                        
                    }

                    Tab(String(localized: "general.tabs.history"), systemImage: "clock", value: 1) {
                        if network.isOnline {
                            HistoryView(sheetGame: $sheetGame, selectedGameId: $selectedGameId, scrolledGameId: $scrolledGameId)
                        } else {
                            OfflineView(showNavBar: .constant(true),title:"general.title.history")
                        }
                    }

                    Tab(String(localized: "general.tabs.stats"), systemImage: "chart.bar", value: 2) {
                        if network.isOnline {
                            StatsView()
                        } else {
                            OfflineView(showNavBar: .constant(true),title:"general.title.statistics")
                        }
                    }

                    Tab(String(localized: "general.tabs.profile"), systemImage: "person", value: 3) {
                        if network.isOnline {
                            ProfileView()
                        }else {
                            OfflineView(showNavBar: .constant(true),title:"general.title.profile")
                        }
                    }
                }
                .animation(.easeInOut, value: network.isOnline)
                .tabViewStyle(.sidebarAdaptable)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .onChange(of: network.isOnline){
                    if network.isOnline {
                        Task{
                            await network.fetch()
                        }
                    }
                }
                .onAppear {
                    Task { await network.fetch() }
                }
                .onAppear {
                    selectedTab = 0
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
        .alert(String(localized: "general.alert.serverUnreachable"), isPresented: $network.fetchFailed) {
            Button(String(localized: "general.alert.retry")) {
                Task {
                    network.isOnline = false
                    await network.fetch()
                }
            }
            Button(String(localized: "general.alert.cancel"), role: .cancel) {
                network.isOnline = false
            }
        } message: {
            Text(String(localized: "general.alert.serverUnreachable.message"))
        }
        .onOpenURL { url in
            if url == URL(string: "tichu://elo") {
                selectedTab = 1
            }
            if url == URL(string: "tichu://stats") {
                selectedTab = 2
            }
            if url.scheme == "tichu", url.host == "game" {
                let gameId = url.lastPathComponent
                selectedTab = 1
                if Int(gameId) != 0 {
                    selectedGameId = Int(gameId)
                    scrolledGameId = Int(gameId)
                    sheetGame = nil
                }
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
