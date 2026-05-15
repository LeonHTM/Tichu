//
//  MainView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI




struct MainView: View {
    
    @AppStorage("selectedTab") private var selectedTab = 0
    @AppStorage("loggedIn") private var loggedIn = false
    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared
   
    private var isDisconnected: Binding<Bool> {
        Binding(
            get: { !socket.connected },
            set: { _ in }
        )
    }
    
    var body: some View {
        if loggedIn == false{
           
                LoginView()
            
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
                await network.fetchFriends(profileId:3)
                await network.fetchFriendRequests(profileId:3)
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

