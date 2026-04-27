//
//  EditRoundsSheetView.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI

struct EditRoundsSheetView: View {
    @Binding var showEditRoundsSheet: Bool
    @Binding var currentGame:tichuGame
    @State private var expandedRows: Set<Int> = []
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(currentGame.rounds.indices, id: \.self) { index in
                    let round = currentGame.rounds[index]
                    let hasExpanded = expandedRows.contains(index)
                    VStack{
                        HStack{
                            Button(){
                                if hasExpanded {
                                                    expandedRows.remove(index)
                                                } else {
                                                    expandedRows.insert(index)
                                                }
                            }label:{
                                Image(systemName: hasExpanded ? "chevron.down" : "chevron.right")
                            }
                            
                            Text("Round \(index + 1)")
                                .fontWeight(.bold)
                                .font(.system(size:20))
                            Spacer()
                            VStack{
                                Text("\(round.tichuPointsTeam1)")
                                Text("\(round.roundPointsTeam1)")
                            }
                            Text("vs")
                            VStack{
                                Text("\(round.tichuPointsTeam2)")
                                Text("\(round.roundPointsTeam2)")
                            }
                        }
                        if hasExpanded == true {
                            Text("Team 1")
                            Text("\(currentGame.player1?.name ?? "Unknown")")
                            Text("\(currentGame.player2?.name ?? "Unknown")")
                            Text("Team 2")
                            Text("\(currentGame.player3?.name ?? "Unknown")")
                            Text("\(currentGame.player4?.name ?? "Unknown")")
                        }
                    }
                }
                .onDelete { indexSet in
                    currentGame.rounds.remove(atOffsets: indexSet)
                }
            }.navigationTitle("Edit game")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                        ToolbarItem(placement:.cancellationAction){
                        Button("Cancel",systemImage:"xmark"){
                            showEditRoundsSheet = false
                        }
                    }
                    ToolbarItem(placement:.confirmationAction){
                        Button("Done", systemImage: "checkmark"){
                            
                            showEditRoundsSheet  = false
                        }
                        
                    }
                }
            
        }
    }
}

#Preview {
    EditRoundsSheetView(showEditRoundsSheet: .constant(true),currentGame:.constant(exampleGame))
}
