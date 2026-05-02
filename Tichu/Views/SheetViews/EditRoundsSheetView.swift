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
    
    private func bombCounter(player:profile, round: Round) -> Int{
        if player.id == round.first?.id {
            return round.firstBombs
        }else if player.id == round.second?.id{
            return round.secondBombs
        }else if player.id == round.second?.id{
            return round.thirdBombs
        }else if player.id == round.second?.id{
            return round.fourthBombs
        }else {
            return 999
        }
    }

    var body: some View {
        NavigationStack {
            if showOffSet == false {
                List {
                    ForEach(Array($currentGame.Rounds), id: \.id) { $currentRound in
                        let index = currentGame.Rounds.firstIndex(where: { $0.id == currentRound.id }) ?? 0
                        let hasExpanded = expandedRows.contains(index)

                        let sortedTeam1 = sortedTeam(team: currentGame.team1 ?? Team(list: []), in: currentRound)
                        let sortedTeam2 = sortedTeam(team: currentGame.team2 ?? Team(list: []), in: currentRound)

                        VStack {

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

                            if hasExpanded {
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

                                                let isFirstIsPlayer2 = (currentRound.first?.id == currentGame.player2?.id)
                                                let isFirstIsPlayer1 = (currentRound.first?.id == currentGame.player1?.id)
                                                let isSecondIsPlayer1 = (currentRound.second?.id == currentGame.player1?.id)
                                                let isSecondIsPlayer2 = (currentRound.second?.id == currentGame.player2?.id)

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

                                                let isFirstIsPlayer4 = (currentRound.first?.id == currentGame.player4?.id)
                                                let isFirstIsPlayer3 = (currentRound.first?.id == currentGame.player3?.id)
                                                let isSecondIsPlayer3 = (currentRound.second?.id == currentGame.player3?.id)
                                                let isSecondIsPlayer4 = (currentRound.second?.id == currentGame.player4?.id)

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
                                }
                                .sheet(isPresented: $showAddRoundSheet) {
                                    AddRoundSheetView(
                                        showAddRoundsSheet: $showAddRoundSheet,
                                        currentGame: $currentGame,
                                        currentRound: $currentRound,
                                        editMode: true
                                    )
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if currentGame.Rounds.count > 1 {
                                    currentGame.Rounds.remove(at: index)
                                } else {
                                    showDeleteGameAlert = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showOffSet = true
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                showAddRoundSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.accentColor)
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
            } else {
                Text(" ")
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
        .alert("Delete this Game?", isPresented: $showDeleteGameAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteGameAlert = false
                showOffSet = false
            }
            Button("Delete", role: .destructive) {
                showEditRoundsSheet = false
                showOffSet = false
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
