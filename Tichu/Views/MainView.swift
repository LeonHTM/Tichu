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
            }.onAppear{
                selectedTab = 0
            }
        }
    }
}

#Preview {
    MainView()
}
