//
//  gameOverViewListView.swift
//  Tichu
//
//  Created by Leon on 02.05.2026.
//

import SwiftUI

struct GameSummaryListView: View {
    @Binding var showGameSummarySheetView: Bool
    var currentGameId: Int?

    let profiles: [Profile]
    @ObservedObject var network: NetworkService

    @State private var rounds: [Round] = []
    @State private var expandedRows: Set<Int> = []
    @State private var showDeleteGameAlert: Bool = false
    @State private var showAddRoundSheet: Bool = false
    @State private var showList: Bool = false
    @State private var editingRoundIndex: Int = 0

    @Environment(\.colorScheme) var colorScheme
    var allowEditing: Bool

    // MARK: - Computed
    
    private var currentGame: Game? {
        network.games.first(where:{$0.id == currentGameId})
    }

    private var allRounds: [Round] {
        rounds.sorted { $0.roundOrder < $1.roundOrder }
    }

    private var winRounds: [Round] {
        allRounds.filter { $0.boolWinRound }
    }

    private func profile(for id: Int?) -> Profile? {
        guard let id else { return nil }
        return profiles.first { $0.id == id }
    }

    private var team1Profiles: [Profile] {
        [profile(for: currentGame?.team1Player1Id ?? 0),
         profile(for: currentGame?.team1Player2Id ?? 0)].compactMap { $0 }
    }

    private var team2Profiles: [Profile] {
        [profile(for: currentGame?.team2Player1Id ?? 0),
         profile(for: currentGame?.team2Player2Id ?? 0)].compactMap { $0 }
    }

    var gameDone: Bool {
        if currentGame?.currentPointsTeam1 ?? 0 >= currentGame?.target ?? 1000 || currentGame?.currentPointsTeam2 ?? 0 >= currentGame?.target ?? 1000 {
            if currentGame?.currentPointsTeam1 ?? 0 > currentGame?.currentPointsTeam2 ?? 0 { return true }
            if currentGame?.currentPointsTeam2 ?? 0 > currentGame?.currentPointsTeam1 ?? 0 { return true }
        }
        return false
    }

    // MARK: - Helpers

    private func place(of profile: Profile, in round: Round) -> Int {
        if round.firstProfileId  == profile.id { return 1 }
        if round.secondProfileId == profile.id { return 2 }
        if round.thirdProfileId  == profile.id { return 3 }
        if round.fourthProfileId == profile.id { return 4 }
        return 999
    }

    private func sortedTeamProfiles(_ teamProfiles: [Profile], in round: Round) -> [Profile] {
        teamProfiles.sorted { place(of: $0, in: round) < place(of: $1, in: round) }
    }

    private func bombCounter(profile: Profile, round: Round) -> Int {
        if round.firstProfileId  == profile.id { return round.firstBombs }
        if round.secondProfileId == profile.id { return round.secondBombs }
        if round.thirdProfileId  == profile.id { return round.thirdBombs }
        if round.fourthProfileId == profile.id { return round.fourthBombs }
        return 0
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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            if !showList {
                List {
                    ForEach(Array(allRounds.enumerated()), id: \.element.id) { index, currentRound in
                        let hasExpanded = expandedRows.contains(index)
                        let isWinningRound = winRounds.contains { $0.id == currentRound.id }
                        let isLocked = !isWinningRound

                        let sortedTeam1 = sortedTeamProfiles(team1Profiles, in: currentRound)
                        let sortedTeam2 = sortedTeamProfiles(team2Profiles, in: currentRound)

                        DisclosureGroup(isExpanded: bindingForExpanded(row: index, disabled: isLocked)) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Team 1").fontWeight(.bold).foregroundStyle(Color.accentColor)
                                        Spacer()
                                        //Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)").fontWeight(.bold).foregroundStyle(Color.accentColor)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)

                                    playerRows(players: sortedTeam1, round: currentRound, teamProfileIds: (currentGame!.team1Player1Id, currentGame!.team1Player2Id))

                                    HStack {
                                        Text("Team 2").fontWeight(.bold)
                                        Spacer()
                                        //Text("\(currentRound.tichu_points_team2 + currentRound.roundPointsTeam2)").fontWeight(.bold)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)

                                    playerRows(players: sortedTeam2, round: currentRound, teamProfileIds: (currentGame!.team2Player1Id, currentGame!.team2Player2Id))
                                }
                                Spacer()
                            }
                            .padding(.leading, -20)
                            .padding(.trailing, 5)

                        } label: {
                            HStack {
                                Text("Round \(index + 1)")
                                    .fontWeight(.bold)
                                    .font(.system(size: 20))
                                    .padding(10)
                                Spacer()
                                if !hasExpanded {
                                    Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)").fontWeight(.bold)
                                    Text("vs").fontWeight(.bold)
                                    Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)").fontWeight(.bold)
                                }
                            }
                        }
                        .opacity(isLocked ? 0.5 : 1.0)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if allowEditing {
                                Button(role: .destructive) {
                                    if allRounds.count > 1 {
                                        /*Task {
                                            await network.deleteRound(gameId: currentGame.id, roundId: currentRound.id)
                                            await network.reCalculate(gameId: currentGame.id)
                                            rounds = network.roundsByGame[currentGame.id] ?? []
                                            let updatedGames: [Game] = network.games
                                            if let updated = updatedGames.first(where: { $0.id == currentGame.id }) {
                                                currentGame = updated
                                            }
                                        }*/
                                    } else {
                                        showDeleteGameAlert = true
                                        showList = true
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                if !isLocked {
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
                    }

                    if allRounds.count != winRounds.count {
                        Section {
                            Text("\(allRounds.count - winRounds.count) Rounds are not being counted. This happens because a Round was edited in such a way, that the winner already won after Round \(winRounds.count).")
                        }
                        .listRowBackground(Color.clear)
                        .foregroundStyle(.secondary)
                    }

                    if !allowEditing {
                        Section {
                            HStack {
                                Spacer()
                                Text("Played on")
                                Text(currentGame?.date ?? Date(), style: .date)
                                Spacer()
                            }
                            .foregroundStyle(Color.secondary)
                        }
                        .listRowBackground(Color.clear)
                        .fontWeight(.bold)
                    }
                }
                .sheet(isPresented: $showAddRoundSheet, onDismiss: {
                    Task {
                        await network.fetchGameRounds(gameId: currentGame?.id ?? 0)
                        await network.reCalculate(gameId: currentGame?.id ?? 0)
                        rounds = network.roundsByGame[currentGame?.id ?? 0] ?? []
                        let updatedGames: [Game] = network.games
                        if let updated = updatedGames.first(where: { $0.id == currentGame?.id ?? 0 }) {
                            //currentGame = updated
                        }
                    }
                }) {
                    /*AddRoundSheetView(
                        showAddRoundsSheet: $showAddRoundSheet,
                        currentGame: $currentGame,
                        rounds: $rounds,
                        editMode: true,
                        roundIndex: editingRoundIndex + 1,
                        editingRound: allRounds[safe: editingRoundIndex],
                        profiles: profiles,
                        network: network
                    )*/
                }
                .id(editingRoundIndex)
                .listSectionSpacing(0)
                .animation(.spring(duration: 0.25), value: expandedRows)
                .animation(.easeInOut(duration: 0.25), value: showList)

            } else {
                Text(" ")
            }
        }
        .onAppear {
            rounds = network.roundsByGame[currentGame?.id ?? 0] ?? []
        }
        .alert("Delete this Game?", isPresented: $showDeleteGameAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteGameAlert = false
                showList = false
            }
            Button("Delete", role: .destructive) {
                Task {
                    await network.deleteGame(gameId: currentGame?.id ?? 0)
                    showGameSummarySheetView = false
                }
            }
        } message: {
            Text("This Game will be deleted")
        }
    }

    // MARK: - Player Rows

    private func playerRows(players: [Profile], round: Round, teamProfileIds: (Int?, Int?)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(players, id: \.id) { player in
                let playerPlace = place(of: player, in: round)
                let isFirst = round.firstProfileId == player.id

                let firstId  = round.firstProfileId
                let secondId = round.secondProfileId
                let teamIds  = [teamProfileIds.0, teamProfileIds.1]
                let isDoubleWin = firstId != nil && secondId != nil &&
                    teamIds.contains(firstId) && teamIds.contains(secondId)
                let placeColor: Color = isDoubleWin
                    ? .green.opacity(colorScheme == .dark ? 0.66 : 1)
                    : .primary

                let tichu    = round.announcedTichu.contains(player.id)
                let bigTichu = round.announcedBigTichu.contains(player.id)
                let pingu    = round.announcedPingu.contains(player.id)
                let bomb     = bombCounter(profile: player, round: round)

                HStack {
                    Text("\(playerPlace).").fontWeight(.bold).foregroundStyle(placeColor)
                    Text(player.name ?? "Unknown")
                    Spacer()

                    if tichu || bigTichu || pingu {
                        HStack {
                            Image(systemName: isFirst ? "checkmark" : "xmark")
                            Text(bigTichu ? "Big Tichu" : pingu ? "Pingu" : "Tichu")
                        }
                        .foregroundStyle(isFirst ? .green : .red)
                        .opacity(colorScheme == .dark ? 0.66 : 1)
                        .offset(x: bomb > 0 ? 40 : 0)
                    }

                    if bomb > 0 {
                        HStack {
                            Image(systemName: "flame").offset(x: 47)
                            Text("\(bomb)").font(.system(size: 12)).offset(x: 37, y: 7)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemGroupedBackground)))
    }
}
