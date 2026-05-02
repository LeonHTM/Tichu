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
    @State private var showDeleteGameAlert: Bool = false
    @State private var showAddRoundSheet: Bool = false
    @State private var showOffSet: Bool = false
    @Environment(\.colorScheme) var colorScheme
  

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
    
    enum PartnerComparison {
        case higher
        case lower
        case equal
    }
    
    private func partnerRankComparison(
        for player: profile,
        in round: Round
    ) -> PartnerComparison? {
        
        guard
            let team1 = currentGame.team1?.list,
            let team2 = currentGame.team2?.list
        else {
            return nil
        }

        // find partner
        let partner: profile?

        if team1.contains(where: { $0.id == player.id }) {
            partner = team1.first(where: { $0.id != player.id })
        } else if team2.contains(where: { $0.id == player.id }) {
            partner = team2.first(where: { $0.id != player.id })
        } else {
            return nil
        }

        guard let partner else { return nil }

        let playerPlace = placement(player: player, in: round)
        let partnerPlace = placement(player: partner, in: round)

        if partnerPlace < playerPlace {
            return .higher   // partner did better
        } else if partnerPlace > playerPlace {
            return .lower    // partner did worse
        } else {
            return .equal
        }
    }


    var body: some View {
        NavigationStack {
            if showOffSet == false{
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
                    
                    
                    
                    VStack {
                        
                        // MARK: Header
                        HStack {
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    if hasExpanded {
                                        expandedRows.remove(index)
                                    } else {
                                        expandedRows.insert(index)
                                    }
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
                                }.transition(.opacity)
                                
                                Text("vs").transition(.opacity)
                                
                                VStack {
                                    Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)")
                                }.transition(.opacity)
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
                                                
                                                
                                                
                                                let placeColor: Color = (place == 1 && isSecondIsPlayer1 || place == 1 && isSecondIsPlayer2 || place == 2 && isFirstIsPlayer1 || place == 2 && isFirstIsPlayer2) ? .green.opacity(colorScheme == .dark ? 0.66 : 1) : .primary
                                                
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
                                            let comparison1 = partnerRankComparison(for: currentGame.player1!, in: currentRound)
                                            
                                            
                                            if tichu1 && isFirst1 {
                                                
                                                if comparison1 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    
                                                    Text("Tichu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison1 == .lower {
                                                    Text(" ")
                                                }
                                            } else if bigTichu1 && isFirst1 {
                                                if comparison1 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    
                                                    Text("Big Tichu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                
                                                if comparison1 == .lower {
                                                    Text(" ")
                                                }
                                                
                                            } else if pingu1 && isFirst1 {
                                                if comparison1 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Pingu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison1 == .lower {
                                                    Text(" ")
                                                }
                                            } else if tichu1 && !isFirst1{
                                                if comparison1 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison1 == .lower {
                                                    Text(" ")
                                                }
                                            } else if bigTichu1 && !isFirst1 {
                                                if comparison1 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Big Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison1 == .lower {
                                                    Text(" ")
                                                }
                                                
                                                
                                            } else if pingu1 && !isFirst1 {
                                                if comparison1 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Pingu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison1 == .lower {
                                                    Text(" ")
                                                }
                                            }
                                            
                                            let comparison2 = partnerRankComparison(for: currentGame.player2!, in: currentRound)
                                            
                                            
                                            if tichu2 && isFirst2 {
                                                if comparison2 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Tichu")
                                                } .foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison2 == .lower {
                                                    Text(" ")
                                                }
                                                
                                            } else if bigTichu2 && isFirst2 {
                                                if comparison2 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Big Tichu")
                                                } .foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison2 == .lower {
                                                    Text(" ")
                                                }
                                            } else if pingu2 && isFirst2 {
                                                if comparison2 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Pingu").foregroundStyle(.green)
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison2 == .lower {
                                                    Text(" ")
                                                }
                                            } else if tichu2 && !isFirst2{
                                                if comparison2 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison2 == .lower {
                                                    Text(" ")
                                                }
                                            } else if bigTichu2 && !isFirst2 {
                                                if comparison2 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Big Tichu")
                                                    
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison2 == .lower {
                                                    Text(" ")
                                                }
                                            } else if pingu2 && !isFirst2{
                                                if comparison2 == .higher {
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Big Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison2 == .lower {
                                                    Text(" ")
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
                                                
                                                
                                                let placeColor: Color = (place == 1 && isSecondIsPlayer4 || place == 1 && isSecondIsPlayer3 || place == 2 && isFirstIsPlayer3 || place == 2 && isFirstIsPlayer4) ? .green.opacity(colorScheme == .dark ? 0.66 : 1) : .primary
                                                
                                                
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
                                            
                                            let comparison3 = partnerRankComparison(for: currentGame.player3!, in: currentRound)
                                            
                                            if tichu3 && isFirst3 {
                                                if comparison3 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Tichu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison3 == .lower{
                                                    Text(" ")
                                                }
                                            } else if bigTichu3 && isFirst3 {
                                                if comparison3 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Big Tichu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison3 == .lower{
                                                    Text(" ")
                                                }
                                            } else if pingu3 && isFirst3 {
                                                if comparison3 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    
                                                    Text("Pingu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison3 == .lower{
                                                    Text(" ")
                                                }
                                            } else if tichu3 && !isFirst3{
                                                if comparison3 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison3 == .lower{
                                                    Text(" ")
                                                }
                                            } else if bigTichu3 && !isFirst3 {
                                                if comparison3 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Big Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison3 == .lower{
                                                    Text(" ")
                                                }
                                                
                                            } else if pingu3 && !isFirst3 {
                                                if comparison3 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Pingu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison3 == .lower{
                                                    Text(" ")
                                                }
                                            }
                                            
                                            
                                            let comparison4 = partnerRankComparison(for: currentGame.player4!, in: currentRound)
                                            
                                            if tichu4 && isFirst4 {
                                                if comparison4 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Tichu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison4 == .lower{
                                                    Text(" ")
                                                }
                                            } else if bigTichu4 && isFirst4 {
                                                if comparison4 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                    Text("Big Tichu")
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison4 == .lower{
                                                    Text(" ")
                                                }
                                            } else if pingu4 && isFirst4 {
                                                if comparison4 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Pingu").foregroundStyle(.green)
                                                }.foregroundStyle(.green).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison4 == .lower{
                                                    Text(" ")
                                                }
                                            } else if tichu4 && !isFirst4{
                                                if comparison4 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison4 == .lower{
                                                    Text(" ")
                                                }
                                            } else if bigTichu4 && !isFirst4 {
                                                if comparison4 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Big Tichu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison4 == .lower{
                                                    Text(" ")
                                                }
                                            } else if pingu4 && !isFirst4 {
                                                if comparison4 == .higher{
                                                    Text(" ")
                                                }
                                                HStack{
                                                    Image(systemName:"xmark")
                                                    Text("Pingu")
                                                }.foregroundStyle(.red).opacity(colorScheme == .dark ? 0.66 : 1)
                                                if comparison4 == .lower{
                                                    Text(" ")
                                                }
                                            }
                                        }.padding(.trailing)
                                        
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(uiColor: .systemGroupedBackground))
                                    )
                                }.sheet(isPresented: $showAddRoundSheet) {
                                    AddRoundSheetView(showAddRoundsSheet: $showAddRoundSheet,currentGame: $currentGame,currentRound: .constant(currentRound))
                                    
                                }
                                
                                Spacer()
                            }.transition(.opacity)
                        }
                    }.swipeActions(edge:.trailing){
                        Button(role:.destructive){
                            if currentGame.Rounds.count > 1{
                                currentGame.Rounds.remove(at:index)
                            }else{
                                showDeleteGameAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) {
                                    showOffSet = true
                                }
                                
                            }
                        }label:{
                            VStack{
                                Image(systemName:"trash")
                                Text("Delete")
                            }
                        }
                        Button(){
                            showAddRoundSheet = true
                         
                            
                        }label:{
                            VStack{
                                Image(systemName:"pencil")
                                Text("Edit")
                            }
                        }.tint(.accentColor)
                    }
                }
                
                
            }
            .animation(.easeInOut(duration: 0.1), value: expandedRows)
            
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
            }else{
                Text(" ").navigationTitle("Edit game").navigationBarTitleDisplayMode(.inline).toolbar {
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
        }.safeAreaInset(edge:.bottom){
            Button{
                showDeleteGameAlert = true
            }label:{
                HStack{
                    Image(systemName:"trash")
                    Text("Delete Game")
                }.foregroundColor(.primary).padding().glassEffect(.regular.interactive())
            }.padding(.bottom,10)
        }.alert("Delete this Game?", isPresented: $showDeleteGameAlert, actions: {
            
            Button(role: .cancel){
                showDeleteGameAlert = false
                showOffSet = false
            }label:{
                Text("Cancel")
            }
            Button(role: .destructive) {
                showEditRoundsSheet = false
                showOffSet = false
                DispatchQueue.main.async {
                    currentGame = tichuGame()
                }
               
                } label: {
                    Text("Delete")
                }
                }, message: {
                    Text("This Game will be deleted")
                })
    }
}

#Preview {
    EditRoundsSheetView(
        showEditRoundsSheet: .constant(true),
        currentGame: .constant(exampleGame)
    )
}

