//
//  HistoryView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI
import Charts

struct HistoryView: View {
    //Storage
    @AppStorage("userImageData") private var userImageData: Data?
    //Vars
    @State private var selectedImage: UIImage?
    @State private var currentGameE = tichuGame()
    @State private var gameHistory: [tichuGame] = exampleHistory
    @State private var showGameSummarySheetView:Bool = false
    
    private func winner(player:profile)->Bool{
        if currentGameE.winner!.list.contains(player){
            return true
        }
        return false
        
    }
    var body: some View {
        NavigationStack{
            GlassEffectContainer{
                ForEach(gameHistory, id: \.id){ currentGame in
                    Button{
                        showGameSummarySheetView = true
                        currentGameE = currentGame
                    }label:{
                        HStack{
                            
                           
                            Text("\(currentGame.currentPointsTeam1) : \(currentGame.currentPointsTeam2)").fontWeight(.bold).font(.title2).padding(.horizontal,10)
                            VStack(alignment:.leading){
                                
                                
                                HStack{
                                    Text("\(currentGame.team1?.list[0].name ?? "Unknown") & \(currentGame.team1?.list[1].name ?? "Unknown")")
                                    Text("vs").fontWeight(.bold)
                                    Text("\(currentGame.team2?.list[0].name ?? "Unknown") & \(currentGame.team2?.list [1].name ?? "Unknown")")
                                }
                                Text(currentGame.date, style: .date).fontWeight(.bold)
                                    
                            }
                            Spacer()
                            
                        }.padding(10).glassEffect(.regular.tint(.gray.opacity(0.2)).interactive(),in:.rect(cornerRadius:24)).padding(.horizontal).foregroundColor(.primary)
                    }
                }
            }.sheet(isPresented: $showGameSummarySheetView){
                GameSummarySheetView(
                    showGameOverViewSheetView: $showGameSummarySheetView,
                    currentGame:$currentGameE,
                    showRevancheButton: false,
                    allowEditing: false
                )
            }.onChange(of:showGameSummarySheetView){
                currentGameE.reCount()
            }
            
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("History")
            .toolbar{
                ToolbarItem(placement:.topBarTrailing){
                    profileImage(selectedImage: selectedImage, size: 44)
                        
                }.sharedBackgroundVisibility(.hidden)
                    
            }
        }.onAppear {
            selectedImage = dataToPhoto(data:userImageData)
        }
    }
}

#Preview {
    HistoryView()
}
