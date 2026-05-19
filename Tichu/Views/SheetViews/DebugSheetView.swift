//
//  DebugSheetView.swift
//  Tichu
//
//  Created by Leon on 06.05.2026.
//

import SwiftUI

struct DebugSheetView: View {
    @Binding var currentGame:tichuGame
    @Binding var showDebugSheetView:Bool
    @Binding var exampleGameHistory: [tichuGame]
    @AppStorage("selectedTab") private var selectedTab = 0
    @ObservedObject private var network = NetworkService.shared
    @ObservedObject var config = Config.shared
 
    
    
    var body: some View {
        NavigationStack{
            VStack{
            Menu{
                Button{
                    currentGame = exampleGame
                   
                }label:{
                    Image(systemName: currentGame.id == exampleGame.id ? "checkmark.circle" :"" )
                    Text("exampleGame1")
                }
                Button{
                    currentGame = exampleGame2
                }label:{
                    Image(systemName: currentGame.id == exampleGame2.id ? "checkmark.circle" : "")
                    Text("exampleGame2")
                }
                Button{
                    currentGame = tichuGame()
                }label:{
                    
                    Text("empty")
                }
            }label:{
                Text("Load example Round")
            }
                TextField("Target",value: $currentGame.target, format: .number)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .foregroundStyle(.secondary)
                    .keyboardType(.numberPad)
                Button{
                    
                    exampleGameHistory =  [exampleGame,exampleGame2,exampleGame3,exampleGame4,exampleGame5,exampleGame6]
                  
                    
                   
                    
                }label:{
                    Text("Load example history")
                }
                Button{
                    Config.shared.switchURL()
                }label:{
                    Text("Switch Server Current: \(Config.shared.baseURL)")
                }.id(Config.shared.baseURL)
                /*ForEach(Array(network.profileImages.keys.sorted()), id: \.self) { id in
                    ProfileImage(data: network.profileImages[id], size: 44)
                }*/
                   
            .navigationTitle(Text("Debug View"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        showDebugSheetView = false
                        currentGame.reCount()
                    }
                }
            }
              
            }
        }
    }
}

#Preview {
    DebugSheetView(currentGame:.constant(exampleGame),showDebugSheetView: .constant(true),exampleGameHistory: .constant([]))
}
