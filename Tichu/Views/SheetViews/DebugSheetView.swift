//
//  DebugSheetView.swift
//  Tichu
//
//  Created by Leon on 06.05.2026.
//

import SwiftUI

struct DebugSheetView: View {
    @Binding var currentGame:Game
    @Binding var showDebugSheetView:Bool
    @AppStorage("userId") var userId: Int = -69420
    @AppStorage("userImageData") var userImageData: Data?
    @AppStorage("userName") var userName: String = "Storage - Unknown"
    @AppStorage("userElo") var userElo: Int = 404
    @AppStorage("selectedTab") private var selectedTab = 0
    @ObservedObject private var network = NetworkService.shared
    @ObservedObject var config = Config.shared
    @State private var reCalculate: String = "0"
 
    
    
    var body: some View {
        NavigationStack{
            VStack{
                TextField("Target",value: $currentGame.target, format: .number)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .foregroundStyle(.secondary)
                    .keyboardType(.numberPad)
            
                Button(action: {
                    Config.shared.switchURL()
                }) {
                    Text("Switch Server Current: \(Config.shared.baseURL)")
                }
                .id(Config.shared.baseURL)
                /*ForEach(Array(network.profileImages.keys.sorted()), id: \.self) { id in
                    ProfileImage(data: network.profileImages[id], size: 44)
                }*/
                TextField("Round to recalculate", text: $reCalculate)
                Button{
                    Task{
                        await network.reCalculate(gameId: Int(reCalculate)!)
                    }
                } label: {
                    Text("Manually recalculate Round \(reCalculate)")
                }
            
                HStack{Text("\(userId)")
                    Text("\(userName)")
                    Text("\(userElo)")
                    ProfileImage(data:userImageData,size:44)
                }
                
              
            }
            .navigationTitle(Text("Debug View"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        showDebugSheetView = false
                        //currentGame.reCount()
                    }
                }
            }
        }
    }
}

/*#Preview {
    DebugSheetView(currentGame:.constant(exampleGame),showDebugSheetView: .constant(true),exampleGameHistory: .constant([]))
}*/
