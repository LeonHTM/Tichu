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
    @State private var sheetGame: Game? = nil
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
                    Tab("Play", systemImage: "play", value: 0) {
                        PlayView()
                    }

                    Tab("History", systemImage: "clock", value: 1) {
                        if socket.connected {
                            HistoryView(sheetGame: $sheetGame, selectedGameId: $selectedGameId, scrolledGameId: $scrolledGameId)
                        } else {
                            OfflineView(showNavBar: .constant(true))
                        }
                    }

                    Tab("Stats", systemImage: "chart.bar", value: 2) {
                        if socket.connected {
                            StatsView()
                        } else {
                            OfflineView(showNavBar: .constant(true))
                        }
                    }

                    Tab("Profile", systemImage: "person", value: 3) {
                        ProfileView()
                    }
                }
                .tabViewStyle(.sidebarAdaptable)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
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
