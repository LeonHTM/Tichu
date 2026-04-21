//
//  HomeView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack{
            HStack{
                Text("yo")
                Image(systemName:"globe")
            }
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar{
                ToolbarItem(placement:.topBarTrailing){
                    Image("pfp")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .clipShape(.circle)
                        
                }.sharedBackgroundVisibility(.hidden)
                    
            }
        }
        
           
    }
}

#Preview {
    HomeView()
}
