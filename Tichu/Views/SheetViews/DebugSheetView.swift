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
    @AppStorage("userElo") var userElo: Double = 404
    @AppStorage("selectedTab") private var selectedTab = 0
    @ObservedObject private var network = NetworkService.shared
    @ObservedObject var config = Config.shared
    @State private var reCalculate: String = "0"
    @AppStorage("statsList") private var statsList: [Int] = []
 
    
    
    var body: some View {
        NavigationStack{
            ScrollView{
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
            
                HStack{Text("Id:\(userId)")
                    Text("Name: \(userName)")
                    Text("Elo: \(userElo)")
                    ProfileImage(data:userImageData,size:44)
                    
                }
                /*ScrollView{
                    Text("\(NetworkService.shared.eloHistory)")
                    EloHistoryChartView(profileId: userId)
                }*/
                
                ForEach(statsList, id: \.self){profileId in
                    Text("\(network.profiles.first(where:{$0.id == profileId})?.name)").fontWeight(.bold)
                    Text("All Time:")
                    Text("\(network.profiles.first(where:{$0.id == profileId})?.allTime)")
                    Text("Year:")
                    Text("\(network.profiles.first(where:{$0.id == profileId})?.year)")
                    Text("Month:")
                    Text("\(network.profiles.first(where:{$0.id == profileId})?.month)")
                    Text("Week:")
                    Text("\(network.profiles.first(where:{$0.id == profileId})?.week)")
                    Text("Day: ")
                    Text("\(network.profiles.first(where:{$0.id == profileId})?.day)")
                }
                
                
                
                HStack{Text("Id:\(userId)")
                    Text("Elo:  \(network.profiles.first(where: {$0.id == userId})?.name ?? "Error")")
                    Text("Elo:  \(network.profiles.first(where: {$0.id == userId})?.elo ?? -69420)")
                    ProfileImage(data:network.profileImages[userId],size:44)
                    
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
