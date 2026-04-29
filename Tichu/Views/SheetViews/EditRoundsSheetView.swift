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

                            VStack {
                                Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)")
                            }

                            Text("vs")

                            VStack {
                                Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)")
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
                                        Image(systemName: currentRound.doubleWinTeam1 ? "checkmark" : "")
                                            .foregroundStyle(.green)
                                        Text(currentRound.doubleWinTeam1 ? "Double Win" : "")
                                            .foregroundStyle(.green)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)

                                    VStack(alignment: .leading, spacing: 10) {

                                        ForEach(sortedTeam1, id: \.id) { player in

                                            let place = placement(player: player, in: currentRound)

                                            HStack {

                                                Text("\(place).")
                                                    .fontWeight(.bold)

                                                Text(player.name ?? "Unknown")

                                                Spacer()

                                                let tichu = currentRound.hasAnnouncedTichu.contains(player)
                                                let bigTichu = currentRound.hasAnnouncedBigTichu.contains(player)
                                                let pingu = currentRound.hasAnnouncedPingu.contains(player)

                                                let isFirst = currentRound.first?.id == player.id
                                                
                                                if player.id == pointsPlayerTeam1?.id {
                                                    if !currentRound.doubleWinTeam1 && !currentRound.doubleWinTeam2{
                                                        Text("\(currentRound.tichuPointsTeam1)")
                                                    }
                                                }

                                            

                                                    if tichu && isFirst {
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Tichu").foregroundStyle(.green)
                                                    } else if bigTichu && isFirst {
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Big Tichu").foregroundStyle(.green)
                                                    } else if pingu && isFirst {
                                                        Image(systemName:"checkmark")
                                                            .foregroundStyle(.green)
                                                        Text("Pingu").foregroundStyle(.green)
                                                    } else if tichu && !isFirst{
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Tichu").foregroundStyle(.red)
                                                    } else if bigTichu && !isFirst {
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Big Tichu").foregroundStyle(.red)
                                                    } else if pingu && !isFirst {
                                                        Image(systemName:"xmark")
                                                            .foregroundStyle(.red)
                                                        Text("Big Tichu").foregroundStyle(.red)
                                                    }

                                            
                                                
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(uiColor: .systemGroupedBackground))
                                    )

                                    // MARK: TEAM 2
                                    HStack {
                                        Text("Team 2").fontWeight(.bold)
                                        Spacer()
                                        Image(systemName: currentRound.doubleWinTeam2 ? "checkmark" : "")
                                            .foregroundStyle(.green)
                                        Text(currentRound.doubleWinTeam2 ? "Double Win" : "")
                                            .foregroundStyle(.green)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)

                                    VStack(alignment: .leading, spacing: 10) {

                                        ForEach(sortedTeam2, id: \.id) { player in

                                            let place = placement(player: player, in: currentRound)

                                            HStack {

                                                Text("\(place).")
                                                    .fontWeight(.bold)

                                                Text(player.name ?? "Unknown")

                                                Spacer()

                                                let tichu = currentRound.hasAnnouncedTichu.contains(player)
                                                let bigTichu = currentRound.hasAnnouncedBigTichu.contains(player)
                                                let pingu = currentRound.hasAnnouncedPingu.contains(player)

                                                let isFirst = currentRound.first?.id == player.id
                                                
                                                if player.id == pointsPlayerTeam2?.id {
                                                    if !currentRound.doubleWinTeam2 && !currentRound.doubleWinTeam1 {
                                                        Text("\(currentRound.tichuPointsTeam2)")
                                                    }
                                                }

                                                if tichu && isFirst {
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Tichu").foregroundStyle(.green)
                                                } else if bigTichu && isFirst {
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Big Tichu").foregroundStyle(.green)
                                                } else if pingu && isFirst {
                                                    Image(systemName:"checkmark")
                                                        .foregroundStyle(.green)
                                                    Text("Pingu").foregroundStyle(.green)
                                                } else if tichu && !isFirst{
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Tichu").foregroundStyle(.red)
                                                } else if bigTichu && !isFirst {
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Big Tichu").foregroundStyle(.red)
                                                } else if pingu && !isFirst {
                                                    Image(systemName:"xmark")
                                                        .foregroundStyle(.red)
                                                    Text("Big Tichu").foregroundStyle(.red)
                                                }

                                  
                                                
                                            }
                                        }
                                    }
                                    .padding()
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


