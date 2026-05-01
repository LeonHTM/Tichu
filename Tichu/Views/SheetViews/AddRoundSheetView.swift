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
                    }
                    
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
                    
                    VStack {
                        HStack {
                            Text("Points")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(currentRound.tichuPointsTeam1)")
                                Spacer()
                                Text("\(currentRound.tichuPointsTeam2)")
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            
                            Slider(
                                value: Binding(
                                    get: { Double(currentRound.tichuPointsTeam1) },
                                    set: {
                                        currentRound.tichuPointsTeam1 = Int($0)
                                        currentRound.tichuPointsTeam2 = 100 - Int($0)
                                    }
                                ),
                                in: -25.0...125.0,
                                step: 5
                            )
                            .padding(.horizontal, 30)
                        }
                        .padding(10)
                        .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                        .padding(.trailing, 15)
                    }
                    .padding(.leading, 20)
                    .padding(.top, -10)
                }
                .navigationTitle("Add Round")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            showAddRoundsSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            showAddRoundsSheet = false
                        }
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .onAppear {
                players = [
                    currentGame.player1,
                    currentGame.player2,
                    currentGame.player3,
                    currentGame.player4
                ]
            }
        }
    }
}

#Preview {
    AddRoundSheetView(
        showAddRoundsSheet: .constant(true),
        currentGame: .constant(exampleGame),
        currentRound: .constant(Round())
    )
}

