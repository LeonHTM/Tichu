//
//  PlayView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct PlayView: View {
    var body: some View {
        NavigationStack{
            HStack{
                Text("yo")
                Image(systemName:"globe")
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("Play")
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
    PlayView()
}
