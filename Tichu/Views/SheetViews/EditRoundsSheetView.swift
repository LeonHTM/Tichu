//
//  EditRoundsSheetView.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI

struct EditRoundsSheetView: View {
    @Binding var showEditRoundsSheet: Bool
    @Binding var currentGame: tichuGame

    @State private var expandedRows: Set<Int> = []

  

    private func placement(player: profile, in round: Round) -> Int {
        if round.first?.id == player.id { return 1 }
        if round.second?.id == player.id { return 2 }
        if round.third?.id == player.id { return 3 }
        if round.fourth?.id == player.id { return 4 }
        return 999
    }

    private func sortedTeam(team: Team, in round: Round) -> [profile] {
        team.list.sorted {
            placement(player: $0, in: round) < placement(player: $1, in: round)
        }
    }

    private func hasAnyAnnouncement(_ player: profile, in round: Round) -> Bool {
        round.hasAnnouncedTichu.contains(player)
        || round.hasAnnouncedBigTichu.contains(player)
        || round.hasAnnouncedPingu.contains(player)
    }

    private func pointsPlayer(in team: [profile], round: Round) -> profile? {
        // Prefer player without announcement
        if let player = team.first(where: { !hasAnyAnnouncement($0, in: round) }) {
            return player
        }
        // fallback: first player
        return team.first
    }

    var body: some View {
        NavigationStack {
            List {

                ForEach(currentGame.Rounds.indices, id: \.self) { index in

                    let currentRound = currentGame.Rounds[index]
                    let hasExpanded = expandedRows.contains(index)

                    let sortedTeam1 = sortedTeam(
                        team: currentGame.team1 ?? Team(list: []),
                        in: currentRound
                    )

                    let sortedTeam2 = sortedTeam(
                        team: currentGame.team2 ?? Team(list: []),
                        in: currentRound
                    )

                    let pointsPlayerTeam1 = pointsPlayer(in: sortedTeam1, round: currentRound)
                    let pointsPlayerTeam2 = pointsPlayer(in: sortedTeam2, round: currentRound)

                    VStack {

                        // MARK: Header
                        HStack {

                            Button {
                                if hasExpanded {
                                    expandedRows.remove(index)
                                } else {
                                    expandedRows.insert(index)
                                }
                            } label: {
                                Image(systemName: hasExpanded ? "chevron.down" : "chevron.right")
                            }

                            Text("Round \(index + 1)")
                                .fontWeight(.bold)
                                .font(.system(size: 20))
                                .padding(10)

                            Spacer()
                            if hasExpanded == false{
                                VStack {
                                    Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)")
                                }
                                
                                Text("vs")
                                
                                VStack {
                                    Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)")
                                }
                            }
                        }

                        // MARK: Expanded
                        if hasExpanded {

                            HStack(alignment: .top) {

                                VStack(alignment: .leading) {
                                    
                                    // MARK: TEAM 1
                                    HStack {
                                        Text("Team 1").fontWeight(.bold)
                                        Spacer()
                                        Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)").fontWeight(.bold)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)
                                    
                                    HStack{
                                        VStack(alignment: .leading, spacing: 10) {
                                            
                                            ForEach(sortedTeam1, id: \.id) { player in
                                                
                                                let place = placement(player: player, in: currentRound)
                                                
                                                //DUDE HOW STUPID IS THIS CODE
                                                let isFirstIsPlayer2 = (currentRound.first?.id == currentGame.player2?.id)
                                                let isFirstIsPlayer1 = (currentRound.first?.id == currentGame.player1?.id)
                                                
                                                let isSecondIsPlayer1 = (currentRound.second?.id == currentGame.player1?.id)
                                                let isSecondIsPlayer2 = (currentRound.second?.id == currentGame.player2?.id)
                                                
                                                
                                                
                                                let placeColor: Color = (place == 1 && isSecondIsPlayer1 || place == 1 && isSecondIsPlayer2 || place == 2 && isFirstIsPlayer1 || place == 2 && isFirstIsPlayer2) ? .green : .primary
                                                
                                                HStack {
                                                    
                                                    Text("\(place).")
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(placeColor)
                                                    
                                                    Text(player.name ?? "Unknown")
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }.padding()
                                        
                                            let tichu1 = currentRound.hasAnnouncedTichu.contains(currentGame.player1 ?? profile())
                                            let bigTichu1 = currentRound.hasAnnouncedBigTichu.contains(currentGame.player1  ?? profile())
                                            let pingu1 = currentRound.hasAnnouncedPingu.contains(currentGame.player1  ?? profile())
                                            
                                            let isFirst1 = currentRound.first?.id == currentGame.player1?.id  ?? profile().id
                                            
                                            
                                            let tichu2 = currentRound.hasAnnouncedTichu.contains(currentGame.player2 ?? profile())
                                            let bigTichu2 = currentRound.hasAnnouncedBigTichu.contains(currentGame.player2  ?? profile())
                                            let pingu2 = currentRound.hasAnnouncedPingu.contains(currentGame.player2  ?? profile())
                                            
                                            let isFirst2 = currentRound.first?.id == currentGame.player2?.id  ?? profile().id
                                            
                                            VStack(alignment:.leading,spacing:10){
                                                
                                                if tichu1 && isFirst1 {
                                                    HStack{
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Tichu").foregroundStyle(.green)
                                                    }
                                                    
                                                        if !tichu2 && !bigTichu2 && !pingu2 {
                                                            Text("")
                                                        }
                                                    
                                                } else if bigTichu1 && isFirst1 {
                                                    HStack{
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Big Tichu").foregroundStyle(.green)
                                                    }
                                                    
                                                        if !tichu2 && !bigTichu2 && !pingu2 {
                                                            Text("")
                                                        }
                                                    
                                                } else if pingu1 && isFirst1 {
                                                    HStack{
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Pingu").foregroundStyle(.green)
                                                    }
                                                    if !tichu2 && !bigTichu2 && !pingu2 {
                                                        Text("")
                                                    }
                                                } else if tichu1 && !isFirst1{
                                                    HStack{
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Tichu").foregroundStyle(.red)
                                                    }
                                                    if !tichu2 && !bigTichu2 && !pingu2 {
                                                        Text("")
                                                    }
                                                } else if bigTichu1 && !isFirst1 {
                                                    HStack{
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Big Tichu").foregroundStyle(.red)
                                                    }
                                                        if !isFirst2 && !tichu2 && !bigTichu2 && !pingu2 {
                                                            Text("")
                                                        }
                                                    
                                                    
                                                } else if pingu1 && !isFirst1 {
                                                    HStack{
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Big Tichu").foregroundStyle(.red)
                                                    }
                                                    if !tichu2 && !bigTichu2 && !pingu2 {
                                                        Text("")
                                                    }
                                                }
                                                
                                                
                                                
                                                if tichu2 && isFirst2 {
                                                    HStack{
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Tichu").foregroundStyle(.green)
                                                        if !tichu1 && !bigTichu1 && !pingu1 {
                                                            Text("")
                                                        }
                                                    }
                                                } else if bigTichu2 && isFirst2 {
                                                    HStack{
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Big Tichu").foregroundStyle(.green)
                                                    }
                                                    if !tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    }
                                                } else if pingu2 && isFirst2 {
                                                    HStack{
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Pingu").foregroundStyle(.green)
                                                    }
                                                    if !tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    }
                                                } else if tichu2 && !isFirst2{
                                                    if isFirst1 && !tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    }
                                                    HStack{
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Tichu").foregroundStyle(.red)
                                                    }
                                                    if !isFirst1 && !tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    }
                                                } else if bigTichu2 && !isFirst2 {
                                                    if isFirst1 && !tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    }
                                                    HStack{
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Big Tichu").foregroundStyle(.red)
                                                        
                                                    }
                                                    if !isFirst1 && !tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    }
                                                } else if pingu2 && !isFirst2{
                                                    if isFirst1 && !tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    }
                                                    HStack{
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Big Tichu").foregroundStyle(.red)
                                                    }
                                                    if !isFirst1 && tichu1 && !bigTichu1 && !pingu1 {
                                                        Text("")
                                                    
                                                    }
                                                }
                                            }
                                            
                                            
                                            
                                            
                                        
                                    
                                    .padding()
                                }
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(uiColor: .systemGroupedBackground))
                                    )

                                    // MARK: TEAM 2
                                    HStack {
                                        Text("Team 2").fontWeight(.bold)
                                        Spacer()
                                        
    
                                        Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)").fontWeight(.bold)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)
                                    HStack{
                                        VStack(alignment: .leading, spacing: 10) {
                                            
                                            ForEach(Array(sortedTeam2.enumerated()), id: \.element.id) { index, player in
                                                
                                                let place = placement(player: player, in: currentRound)
                                                
                                                let isFirstIsPlayer4 = (currentRound.first?.id == currentGame.player4?.id)
                                                let isFirstIsPlayer3 = (currentRound.first?.id == currentGame.player3?.id)
                                                
                                                let isSecondIsPlayer3 = (currentRound.second?.id == currentGame.player3?.id)
                                                let isSecondIsPlayer4 = (currentRound.second?.id == currentGame.player4?.id)
                                                
        
                                                let placeColor: Color = (place == 1 && isSecondIsPlayer4 || place == 1 && isSecondIsPlayer3 || place == 2 && isFirstIsPlayer3 || place == 2 && isFirstIsPlayer4) ? .green : .primary
                                                
                                                
                                                HStack {
                                                    
                                                    Text("\(place).")
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(placeColor)
                                                    
                                                    Text(player.name ?? "Unknown")
                                                    
                                                    Spacer()
                                                }
                                                
                                                // Only add Spacer if it's NOT the last element
                                                if index != sortedTeam2.count - 1 {
                                                    
                                                }
                                            }
                                            
                                        }
                                        .padding()
                                        let tichu3 = currentRound.hasAnnouncedTichu.contains(currentGame.player3 ?? profile())
                                        let bigTichu3 = currentRound.hasAnnouncedBigTichu.contains(currentGame.player3  ?? profile())
                                        let pingu3 = currentRound.hasAnnouncedPingu.contains(currentGame.player3  ?? profile())
                                        
                                        let isFirst3 = currentRound.first?.id == currentGame.player3?.id  ?? profile().id
                                        
                                        
                                        let tichu4 = currentRound.hasAnnouncedTichu.contains(currentGame.player4 ?? profile())
                                        let bigTichu4 = currentRound.hasAnnouncedBigTichu.contains(currentGame.player4  ?? profile())
                                        let pingu4 = currentRound.hasAnnouncedPingu.contains(currentGame.player4  ?? profile())
                                        
                                        let isFirst4 = currentRound.first?.id == currentGame.player4?.id  ?? profile().id
                                    
                                        VStack(alignment:.leading,spacing:11){
                                             
                                            if tichu3 && isFirst3 {
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Tichu").foregroundStyle(.green)
                                                }
                                                if !tichu4 && !bigTichu4 && !pingu4 {
                                                    Text("")
                                                }
                                            } else if bigTichu3 && isFirst3 {
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Big Tichu").foregroundStyle(.green)
                                                    }
                                                if !tichu4 && !bigTichu4 && !pingu4 {
                                                    Text("")
                                                }
                                            } else if pingu3 && isFirst3 {
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Pingu").foregroundStyle(.green)
                                                }
                                                if !tichu4 && !bigTichu4 && !pingu4 {
                                                    Text("")
                                                }
                                            } else if tichu3 && !isFirst3{
                                                HStack{
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Tichu").foregroundStyle(.red)
                                                }
                                                if !tichu4 && !bigTichu4 && !pingu4 {
                                                    Text("")
                                                }
                                            } else if bigTichu3 && !isFirst3 {
                                                HStack{
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Big Tichu").foregroundStyle(.red)
                                                }
                                                if !tichu4 && !bigTichu4 && !pingu4 {
                                                    Text("")
                                                }
                                               
                                            } else if pingu3 && !isFirst3 {
                                                HStack{
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Big Tichu").foregroundStyle(.red)
                                                }
                                                if !tichu4 && !bigTichu4 && !pingu4 {
                                                    Text("")
                                                }
                                            }
                                            
                                            /*if currentRound.doubleWinTeam2 {
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Double Win")
                                                        .foregroundStyle(.green)
                                                }
                                            }*/
                                            
                                            if tichu4 && isFirst4 {
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Tichu").foregroundStyle(.green)
                                                }
                                                if !tichu3 && !bigTichu3 && !pingu3 {
                                                    Text("")
                                                }
                                            } else if bigTichu4 && isFirst4 {
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Big Tichu").foregroundStyle(.green)
                                                    }
                                                if !tichu3 && !bigTichu3 && !pingu3 {
                                                    Text("")
                                                }
                                            } else if pingu4 && isFirst4 {
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Pingu").foregroundStyle(.green)
                                                }
                                                if !tichu3 && !bigTichu3 && !pingu3 {
                                                    Text("")
                                                }
                                            } else if tichu4 && !isFirst4{
                                                HStack{
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Tichu").foregroundStyle(.red)
                                                }
                                                if !tichu3 && !bigTichu3 && !pingu3 {
                                                    Text("")
                                                }
                                            } else if bigTichu4 && !isFirst4 {
                                                HStack{
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Big Tichu").foregroundStyle(.red)
                                                   
                                                }
                                                if !tichu3 && !bigTichu3 && !pingu3 {
                                                    Text("")
                                                }
                                            } else if pingu4 && !isFirst4 {
                                                HStack{
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Big Tichu").foregroundStyle(.red)
                                                }
                                                if !tichu3 && !bigTichu3 && !pingu3 {
                                                    Text("")
                                                }
                                            }
                                        }.padding(.trailing)
                                        
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(uiColor: .systemGroupedBackground))
                                    )
                                }

                                Spacer()
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    currentGame.Rounds.remove(atOffsets: indexSet)
                }
            }

            .navigationTitle("Edit game")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        showEditRoundsSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        showEditRoundsSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    EditRoundsSheetView(
        showEditRoundsSheet: .constant(true),
        currentGame: .constant(exampleGame)
    )
}
