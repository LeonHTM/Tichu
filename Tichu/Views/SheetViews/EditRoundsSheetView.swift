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

    // MARK: - Placement logic

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

                    VStack {

                       
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

                            Spacer()

                            VStack {
                                Text("\(currentRound.tichuPointsTeam1)")
                                Text("\(currentRound.roundPointsTeam1)")
                            }

                            Text("vs")

                            VStack {
                                Text("\(currentRound.tichuPointsTeam2)")
                                Text("\(currentRound.roundPointsTeam2)")
                            }
                        }

                        // MARK: Expanded
                        if hasExpanded {

                            HStack(alignment: .top) {

                                VStack(alignment: .leading) {

                                    // TEAM 1
                                    Text("Team 1")
                                        .fontWeight(.bold)
                                        .padding()

                                    VStack(alignment: .leading, spacing: 10) {

                                        ForEach(sortedTeam1, id: \.id) { player in

                                            let place = placement(player: player, in: currentRound)

                                            HStack {

                                                Text("\(place).")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(
                                                        place == 1 ? .accentColor :
                                                        place == 2 ? .silver :
                                                        place == 3 ? .bronce :
                                                        .primary
                                                    )

                                                Text(player.name ?? "Unknown")
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(uiColor: .systemGroupedBackground))
                                    )

                                    // TEAM 2
                                    Text("Team 2")
                                        .fontWeight(.bold)
                                        .padding()

                                    VStack(alignment: .leading, spacing: 10) {

                                        ForEach(sortedTeam2, id: \.id) { player in

                                            let place = placement(player: player, in: currentRound)

                                            HStack {

                                                Text("\(place).")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(
                                                        place == 1 ? .accentColor :
                                                        place == 2 ? .silver :
                                                        place == 3 ? .bronce :
                                                        .green
                                                    )

                                                Text(player.name ?? "Unknown")
                                                Spacer()
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
            .toolbar{ ToolbarItem(placement:.cancellationAction){
                Button("Cancel",systemImage:"xmark"){
                    showEditRoundsSheet = false
                }
            }
                ToolbarItem(placement:.confirmationAction)
                { Button("Done", systemImage: "checkmark")
                    { showEditRoundsSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    EditRoundsSheetView(showEditRoundsSheet: .constant(true),
                        currentGame:.constant(exampleGame))
}
