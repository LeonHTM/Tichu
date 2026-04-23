//
//  MainView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI




struct MainView: View {
    
    @State private var selectedTab = 0
   
    var body: some View {
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
        }
    }
}

#Preview {
    MainView()
}
