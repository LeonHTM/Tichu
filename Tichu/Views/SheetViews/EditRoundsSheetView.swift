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
    @State private var currentGameCopy: tichuGame = tichuGame()
    @State private var currentRound = Round()
    @State private var expandedRows: Set<Int> = []
    @State private var showDeleteGameAlert: Bool = false
    @State private var showAddRoundSheet: Bool = false
    @State private var showList: Bool = false
    @State private var editingRoundIndex: Int = 0
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
    
    private func bombCounter(player:profile, round: Round) -> Int{
        if player.id == round.first?.id {
            return round.firstBombs
        }else if player.id == round.second?.id{
            return round.secondBombs
        }else if player.id == round.third?.id{
            return round.thirdBombs
        }else if player.id == round.fourth?.id{
            return round.fourthBombs
        }else {
            return 999
        }
    }
    
    private func bindingForExpanded(row index: Int, disabled: Bool = false) -> Binding<Bool> {
        Binding(
            get: { expandedRows.contains(index) },
            set: { newValue in
                guard !disabled else { return }
                if newValue { expandedRows.insert(index) } else { expandedRows.remove(index) }
            }
        )
    }

    var body: some View {
        NavigationStack {
            
            if showList == false {
                
                List {
                    
                    ForEach(Array($currentGameCopy.Rounds), id: \.id) { $currentRound in
                        let index = currentGameCopy.Rounds.firstIndex(where: { $0.id == currentRound.id }) ?? 0
                        let hasExpanded = expandedRows.contains(index)
                        let isWinningRound = currentGameCopy.winRounds.contains { $0.id == currentRound.id }
                        let isLocked = !isWinningRound
                        
                        let sortedTeam1 = sortedTeam(team: currentGameCopy.team1 ?? Team(list: []), in: currentRound)
                        let sortedTeam2 = sortedTeam(team: currentGameCopy.team2 ?? Team(list: []), in: currentRound)
                        
                        DisclosureGroup(isExpanded: bindingForExpanded(row: index, disabled: isLocked)) {
                            HStack(alignment: .top) {
                                
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Text("Team 1").fontWeight(.bold)
                                        Spacer()
                                        Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)").fontWeight(.bold)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)
                                    
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        ForEach(sortedTeam1, id: \.id) { player in
                                            
                                            let place = placement(player: player, in: currentRound)
                                            let isFirst = currentRound.first?.id == player.id
                                            
                                            let isFirstIsPlayer2 = (currentRound.first?.id == currentGameCopy.player2?.id)
                                            let isFirstIsPlayer1 = (currentRound.first?.id == currentGameCopy.player1?.id)
                                            let isSecondIsPlayer1 = (currentRound.second?.id == currentGameCopy.player1?.id)
                                            let isSecondIsPlayer2 = (currentRound.second?.id == currentGameCopy.player2?.id)
                                            
                                            let placeColor: Color = (place == 1 && isSecondIsPlayer1 || place == 1 && isSecondIsPlayer2 || place == 2 && isFirstIsPlayer1 || place == 2 && isFirstIsPlayer2) ? .green.opacity(colorScheme == .dark ? 0.66 : 1) : .primary
                                            
                                            let tichu = currentRound.hasAnnouncedTichu.contains(player)
                                            let bigTichu = currentRound.hasAnnouncedBigTichu.contains(player)
                                            let pingu = currentRound.hasAnnouncedPingu.contains(player)
                                            
                                            HStack {
                                                Text("\(place).")
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(placeColor)
                                                
                                                Text(player.name ?? "Unknown")
                                                
                                                Spacer()
                                                let bomb = bombCounter(player:player,round:currentRound)
                                                
                                                if tichu && isFirst {
                                                    HStack {
                                                        Image(systemName: "checkmark")
                                                        Text("Tichu")
                                                    }.foregroundStyle(.green)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if bigTichu && isFirst {
                                                    HStack {
                                                        Image(systemName: "checkmark")
                                                        Text("Big Tichu")
                                                    }.foregroundStyle(.green)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if pingu && isFirst {
                                                    HStack {
                                                        Image(systemName: "checkmark")
                                                        Text("Pingu1")
                                                    }.foregroundStyle(.green)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if tichu && !isFirst {
                                                    HStack {
                                                        Image(systemName: "xmark")
                                                        Text("Tichu")
                                                    }.foregroundStyle(.red)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if bigTichu && !isFirst {
                                                    HStack {
                                                        Image(systemName: "xmark")
                                                        Text("Big Tichu")
                                                    }.foregroundStyle(.red)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if pingu && !isFirst {
                                                    HStack {
                                                        Image(systemName: "xmark")
                                                        Text("Pingu1")
                                                    }.foregroundStyle(.red)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                }
                                                HStack{
                                                    if bomb == 1{
                                                        Image(systemName:"flame").offset(x:47)
                                                        Text("1").font(.system(size: 12)).offset(x:37,y:7)
                                                    } else if bomb == 2{
                                                        Image(systemName:"flame").offset(x:47)
                                                        Text("2").font(.system(size: 12)).offset(x:37,y:7)
                                                        
                                                    }else if bomb == 3{
                                                        Image(systemName:"flame").offset(x:47)
                                                        Text("3").font(.system(size: 12)).offset(x:37,y:7)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemGroupedBackground)))
                                    
                                    HStack {
                                        Text("Team 2").fontWeight(.bold)
                                        Spacer()
                                        Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)").fontWeight(.bold)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        ForEach(sortedTeam2, id: \.id) { player in
                                            
                                            let place = placement(player: player, in: currentRound)
                                            let isFirst = currentRound.first?.id == player.id
                                            
                                            let isFirstIsPlayer4 = (currentRound.first?.id == currentGameCopy.player4?.id)
                                            let isFirstIsPlayer3 = (currentRound.first?.id == currentGameCopy.player3?.id)
                                            let isSecondIsPlayer3 = (currentRound.second?.id == currentGameCopy.player3?.id)
                                            let isSecondIsPlayer4 = (currentRound.second?.id == currentGameCopy.player4?.id)
                                            
                                            let placeColor: Color = (place == 1 && isSecondIsPlayer4 || place == 1 && isSecondIsPlayer3 || place == 2 && isFirstIsPlayer3 || place == 2 && isFirstIsPlayer4) ? .green.opacity(colorScheme == .dark ? 0.66 : 1) : .primary
                                            
                                            let tichu = currentRound.hasAnnouncedTichu.contains(player)
                                            let bigTichu = currentRound.hasAnnouncedBigTichu.contains(player)
                                            let pingu = currentRound.hasAnnouncedPingu.contains(player)
                                            
                                            HStack {
                                                Text("\(place).")
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(placeColor)
                                                
                                                Text(player.name ?? "Unknown")
                                                
                                                Spacer()
                                                
                                                let bomb = bombCounter(player:player,round:currentRound)
                                                
                                                if tichu && isFirst {
                                                    HStack {
                                                        Image(systemName: "checkmark")
                                                        Text("Tichu")
                                                    }.foregroundStyle(.green)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if bigTichu && isFirst {
                                                    HStack {
                                                        Image(systemName: "checkmark")
                                                        Text("Big Tichu")
                                                    }.foregroundStyle(.green)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if pingu && isFirst {
                                                    HStack {
                                                        Image(systemName: "checkmark")
                                                        Text("Pingu1")
                                                    }.foregroundStyle(.green)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if tichu && !isFirst {
                                                    HStack {
                                                        Image(systemName: "xmark")
                                                        Text("Tichu")
                                                    }.foregroundStyle(.red)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if bigTichu && !isFirst {
                                                    HStack {
                                                        Image(systemName: "xmark")
                                                        Text("Big Tichu")
                                                    }.foregroundStyle(.red)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                } else if pingu && !isFirst {
                                                    HStack {
                                                        Image(systemName: "xmark")
                                                        Text("Pingu1")
                                                    }.foregroundStyle(.red)
                                                        .opacity(colorScheme == .dark ? 0.66 : 1).offset(x: bomb > 0 ? 40 : 0)
                                                }
                                                HStack{
                                                    if bomb == 1{
                                                        Image(systemName:"flame").offset(x:47)
                                                        Text("1").font(.system(size: 12)).offset(x:37,y:7)
                                                    } else if bomb == 2{
                                                        Image(systemName:"flame").offset(x:47)
                                                        Text("2").font(.system(size: 12)).offset(x:37,y:7)
                                                        
                                                    }else if bomb == 3{
                                                        Image(systemName:"flame").offset(x:47)
                                                        Text("3").font(.system(size: 12)).offset(x:37,y:7)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemGroupedBackground)))
                                }
                                
                                Spacer()
                            }.padding(.top,-20).padding(.leading,-20).padding(.trailing,5)
                            
                        } label: {
                            HStack {
                                Text("Round \(index + 1)")
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                    .padding(10)
                                
                                Spacer()
                                
                                if !hasExpanded {
                                    VStack {
                                        Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)")
                                    }.fontWeight(.bold)
                                    
                                    Text("vs").fontWeight(.bold)
                                    
                                    VStack {
                                        Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)")
                                    }.fontWeight(.bold)
                                }
                            }
                        }
                        .opacity(isLocked ? 0.5 : 1.0)
                        .swipeActions(edge: .trailing) {
                           
                                Button(role: .destructive) {
                                    if currentGameCopy.Rounds.count > 1 {
                                        currentGameCopy.Rounds.remove(at: index)
                                        currentGameCopy.reCount()
                                    } else {
                                        showDeleteGameAlert = true
                                        
                                        showList = true
                                        
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            if !isLocked{
                                Button {
                                    
                                    editingRoundIndex = index
                             
                          
                                    showAddRoundSheet = true
                                    
                                    
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.accentColor)
                            }
                        }
                    }
                    if currentGameCopy.Rounds.count != currentGameCopy.winRounds.count{
                        Section{
                            Text("\(currentGameCopy.Rounds.count - currentGameCopy.winRounds.count) Rounds are not being counted. This happens because a Round was edited in such a way, that \(currentGameCopy.winner?.name ?? "Unknown") already won after Round \(currentGameCopy.winRounds.count).")
                        }.listRowBackground(Color.clear).foregroundStyle(.secondary)
                        
                    }
                }
                .sheet(isPresented: $showAddRoundSheet) {
                   
                         let roundBinding = Binding<Round>(
                            get: { currentGameCopy.Rounds[editingRoundIndex] },
                            set: { currentGameCopy.Rounds[editingRoundIndex] = $0 }
                        )
                        
                        AddRoundSheetView(
                            showAddRoundsSheet: $showAddRoundSheet,
                            currentGame: $currentGameCopy,
                            currentRound: roundBinding,
                            editMode: true,
                            roundIndex: editingRoundIndex+1
                        )
                    
                }.id(editingRoundIndex)
                .zIndex(0)
                .listSectionSpacing(0)
                .animation(.spring(duration:0.25),value:expandedRows)
                .animation(.easeInOut(duration:0.25),value:showList)
                //.animation(.easeInOut(duration: 0.25), value: expandedRows)
                .navigationTitle("Edit Game")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel", systemImage: "xmark") {
                                            showEditRoundsSheet = false
                                        }
                                    }
                                    
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Done", systemImage: "checkmark") {
                                            currentGame = currentGameCopy
                                            currentGame.reCount()
                                            showEditRoundsSheet = false
                                        }
                                    }
                                
                            }
            }
                
            else {
                Text(" ")
                    
                    .navigationTitle("Edit Game")
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
            
        }.onAppear{
            currentGameCopy = currentGame
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showDeleteGameAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Game")
                }
                .foregroundColor(.primary)
                .padding()
                .glassEffect(.regular.interactive())
            }
            .padding(.bottom, 10)
        }
        .safeAreaInset(edge: .top) {
            HStack{
                Text("Team 1:")
                Text("\(currentGameCopy.currentPointsTeam1)")
                Spacer()
                Text("Team 2:")
                Text("\(currentGameCopy.currentPointsTeam2)")
            }.fontWeight(.bold).font(.title2).padding(.horizontal,30).padding(.top, 65).padding(.bottom,20)
        }
        .alert("Delete this Game?", isPresented: $showDeleteGameAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteGameAlert = false
                showList = false
            }
            Button("Delete", role: .destructive) {
                showEditRoundsSheet = false
                showList = false
                DispatchQueue.main.async {
                    currentGame = tichuGame()
                }
            }
        } message: {
            Text("This Game will be deleted")
        }
    }
}

#Preview {
    EditRoundsSheetView(
        showEditRoundsSheet: .constant(true),
        currentGame: .constant(exampleGame)
    )
}

