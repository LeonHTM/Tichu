//
//  AddRoundSheetView.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI

struct AddRoundSheetView: View {
    
    @State private var hasAnnouncedPlayer1: CanAnnounce = .none
    @State private var hasAnnouncedPlayer2: CanAnnounce = .none
    @State private var hasAnnouncedPlayer3: CanAnnounce = .none
    @State private var hasAnnouncedPlayer4: CanAnnounce = .none
    @State private var players: [profile?] = []
    @Binding var showAddRoundsSheet: Bool
    @Binding var currentGame: tichuGame
    @Binding var currentRound: Round
    @Environment(\.colorScheme) var colorScheme
    var editMode: Bool
    
    private var displayTeam1Points: Int {
        if hasDoubleWinTeam1 {
            return 100
        }
        if hasDoubleWinTeam2 {
            return 0
        }
        return currentRound.tichuPointsTeam1
    }

    private var displayTeam2Points: Int {
        if hasDoubleWinTeam2 {
            return 100
        }
        if hasDoubleWinTeam1 {
            return 0
        }
        return currentRound.tichuPointsTeam2
    }
    
    private func applyDoubleWin() {
        if hasDoubleWinTeam1 {
            currentRound.tichuPointsTeam1 = 100
            currentRound.tichuPointsTeam2 = 0
        } else if hasDoubleWinTeam2 {
            currentRound.tichuPointsTeam1 = 0
            currentRound.tichuPointsTeam2 = 100
        }
    }
   
    
    func move(from source: IndexSet, to destination: Int) {
        players.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Team logic
    private func isTeam1(_ player: profile?) -> Bool {
        guard let player else { return false }
        return player.id == currentGame.player1?.id || player.id == currentGame.player2?.id
    }
    
    private func isTeam2(_ player: profile?) -> Bool {
        guard let player else { return false }
        return player.id == currentGame.player3?.id || player.id == currentGame.player4?.id
    }
    
   
    private func isGolden(index: Int) -> Bool {
        guard index < 2 else { return false }
        guard players.count >= 2 else { return false }
        
        let first = players[0]
        let second = players[1]
        
        if let first, let second {
            let sameTeam = (isTeam1(first) && isTeam1(second)) ||
                          (isTeam2(first) && isTeam2(second))
            return sameTeam
        }
        return false
    }
    
    func announcement(for player: profile?) -> CanAnnounce {
        guard let player else { return .none }

        if currentRound.hasAnnouncedBigTichu.contains(where: { $0.id == player.id }) {
            return .bigTichu
        }

        if currentRound.hasAnnouncedTichu.contains(where: { $0.id == player.id }) {
            return .tichu
        }

        if currentRound.hasAnnouncedPingu.contains(where: { $0.id == player.id }) {
            return .pingu
        }

        return .none
    }
    
    
    func updateAnnouncement(
        player: profile,
        state: CanAnnounce
    ) {
        currentRound.hasAnnouncedTichu.removeAll { $0.id == player.id }
        currentRound.hasAnnouncedBigTichu.removeAll { $0.id == player.id }
        currentRound.hasAnnouncedPingu.removeAll { $0.id == player.id }

        switch state {
        case .tichu:
            currentRound.hasAnnouncedTichu.append(player)

        case .bigTichu:
            currentRound.hasAnnouncedBigTichu.append(player)

        case .pingu:
            currentRound.hasAnnouncedPingu.append(player)

        case .none:
            break
        }
    }
    
    func saveRound(){
        currentRound.first = players[0]
        currentRound.second = players[1]
        currentRound.third = players[2]
        currentRound.fourth = players[3]
        
        updateAnnouncement(player: currentGame.player1!, state: hasAnnouncedPlayer1)
        updateAnnouncement(player: currentGame.player2!, state: hasAnnouncedPlayer2)
        updateAnnouncement(player: currentGame.player3!, state: hasAnnouncedPlayer3)
        updateAnnouncement(player: currentGame.player4!, state: hasAnnouncedPlayer4)
        
        applyDoubleWin()
        if !editMode {
            currentGame.addRound(addedRound: currentRound)
            currentRound = Round()
        }
    }
    
    
    
    private var hasDoubleWinTeam1: Bool {
        guard
            players.count >= 2,
            let first = players[0],
            let second = players[1],
            let team1 = currentGame.team1
        else {
            return false
        }

        return team1.list.contains(where: { $0.id == first.id }) &&
               team1.list.contains(where: { $0.id == second.id })
    }

    private var hasDoubleWinTeam2: Bool {
        guard
            players.count >= 2,
            let first = players[0],
            let second = players[1],
            let team2 = currentGame.team2
        else {
            return false
        }

        return team2.list.contains(where: { $0.id == first.id }) &&
               team2.list.contains(where: { $0.id == second.id })
    }
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack {
                    HStack {
                        GlassEffectContainer {
                            VStack(alignment: .leading) {
                                Text("Team 1")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                VStack {
                                    playerContainer(player: currentGame.player1 ?? profile(), hasAnnounced: $hasAnnouncedPlayer1, bombNumber: $currentRound.player1Bombs)
                                    playerContainer(player: currentGame.player2 ?? profile(), hasAnnounced: $hasAnnouncedPlayer2, bombNumber: $currentRound.player2Bombs)
                                }
                                .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Team 2")
                                .font(.title2)
                                .fontWeight(.bold)
                            VStack {
                                playerContainer(player: currentGame.player3 ?? profile(), hasAnnounced: $hasAnnouncedPlayer3, bombNumber: $currentRound.player3Bombs)
                                playerContainer(player: currentGame.player4 ?? profile(), hasAnnounced: $hasAnnouncedPlayer4, bombNumber: $currentRound.player4Bombs)
                            }
                            .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                        }
                    }
                    
                    HStack {
                        Text("Placement")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        Spacer()
                    }.zIndex(1 )
                    
                    List {
                        ForEach(Array(players.enumerated()), id: \.element?.id) { index, player in
                            let golden = isGolden(index: index)
                            
        
                            
                            HStack {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                    .foregroundStyle(golden ? Color.accentColor : Color.primary)
                                
                                Text(player?.name ?? "Unknown")
                                Spacer()
                            }
                        }
                        .onMove(perform: move)
                    }
                    .environment(\.editMode, .constant(.active))
                    .listRowBackground(Color.green)
                    .frame(height: 250)
                    .scrollDisabled(true)
                    .padding(.top, -40)
                    .zIndex(0)
                    
                    VStack {
                        HStack {
                            Text("Points 1")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text("Points 2").font(.title2)
                                .fontWeight(.bold)
                        }.padding(.trailing,20)
                        VStack(alignment: .leading) {
                            HStack {
                                
                                Text("\(displayTeam1Points)").font(.title2)
                                    .fontWeight(.bold)
                                
                                if hasDoubleWinTeam1 || hasDoubleWinTeam2 {
                                    Spacer()
                                    Text("Double Win!").foregroundStyle(Color.accentColor)
                                    
                                }
                                Spacer()
                                
                           
                                Text("\(displayTeam2Points)").font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            
                            Slider(
                                value: Binding(
                                    get: {
                                        if hasDoubleWinTeam1 {
                                            return 100
                                        }else if hasDoubleWinTeam2{
                                            return 0
                                        }
                                        return Double(currentRound.tichuPointsTeam1)
                                    },
                                    set: { newValue in
                                        guard !hasDoubleWinTeam1 else { return }
                                        currentRound.tichuPointsTeam1 = Int(newValue)
                                        currentRound.tichuPointsTeam2 = 100 - Int(newValue)
                                    }
                                ),
                                in: -25...125,
                                step: 5
                            )
                            .disabled(hasDoubleWinTeam1 || hasDoubleWinTeam2)
                            .padding(.horizontal, 30)
                        }
                        .padding(10)
                        .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                        .padding(.trailing, 15)
                    }
                    .padding(.leading, 20)
                    .padding(.top, -10)
                }
                .navigationTitle(editMode == true ? "Edit Round" :"Add Round")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            showAddRoundsSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            saveRound()
                            showAddRoundsSheet = false
                        }
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .onAppear {
                if editMode {
                    players = [
                        currentRound.first,
                        currentRound.second,
                        currentRound.third,
                        currentRound.fourth,
                    ]
                }else{
                    players = [
                        currentGame.player1,
                        currentGame.player3,
                        currentGame.player2,
                        currentGame.player4
                    ]
                }

            
                hasAnnouncedPlayer1 = announcement(for: currentGame.player1)
                hasAnnouncedPlayer2 = announcement(for: currentGame.player2)
                hasAnnouncedPlayer3 = announcement(for: currentGame.player3)
                hasAnnouncedPlayer4 = announcement(for: currentGame.player4)
            }
        }
    }
}

#Preview {
    AddRoundSheetView(
        showAddRoundsSheet: .constant(true),
        currentGame: .constant(exampleGame),
        currentRound: .constant(exampleRound6),
        editMode: false
    )
}

