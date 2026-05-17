//
//  MainView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI




struct MainView: View {
    
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage("userId") private var userId = -69420
    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared
   
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
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
                    .tag(1)
                
                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }
                    .tag(2)
                
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
                Alert(
                    title: Text("Connection Issue"),
                    message: Text("Could not connect to server."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    MainView()
}

