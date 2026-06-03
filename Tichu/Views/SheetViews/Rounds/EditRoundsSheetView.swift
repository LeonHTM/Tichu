//
//  EditRoundsSheetView.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI
import TipKit
import Combine

struct EditRoundsSheetView: View {

    // MARK: - Bindings
    @Binding var showEditRoundsSheet: Bool
    var currentGameId: Int

    // MARK: - Dependencies
    let profiles: [Profile]
    @ObservedObject var network: NetworkService
    @StateObject private var socket = SocketService.shared

    @State private var roundsCopy: [Round] = []
    @State private var gameCopy: Game? = nil

    @State private var deletedRoundIds: Set<Int> = []
    @State private var editedRounds: [Int: Round] = [:]

    // MARK: - State
    @State private var expandedRows: Set<Int> = []
    @State private var showDeleteGameAlert: Bool = false
    @State private var showAddRoundSheet: Bool = false
    @State private var showList: Bool = false
    @State private var editingRoundIndex: Int = 0
    @State private var isSaving: Bool = false
    var listSwipeTip = ListSwipeTip()

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Computed from COPY

    private var currentGame: Game? { gameCopy }

    private var allRounds: [Round] {
        roundsCopy.sorted { $0.roundOrder < $1.roundOrder }
    }

    private var winRounds: [Round] {
        allRounds.filter { $0.boolWinRound }
    }

    private var copyPointsTeam1: Int {
        winRounds.reduce(0) { $0 + $1.tichuPointsTeam1 + $1.roundPointsTeam1 }
    }

    private var copyPointsTeam2: Int {
        winRounds.reduce(0) { $0 + $1.tichuPointsTeam2 + $1.roundPointsTeam2 }
    }

    private func profile(for id: Int?) -> Profile? {
        guard let id else { return nil }
        return profiles.first { $0.id == id }
    }

    private var team1Profiles: [Profile] {
        [profile(for: currentGame?.team1Player1Id),
         profile(for: currentGame?.team1Player2Id)].compactMap { $0 }
    }

    private var team2Profiles: [Profile] {
        [profile(for: currentGame?.team2Player1Id),
         profile(for: currentGame?.team2Player2Id)].compactMap { $0 }
    }

    // MARK: - Sync

    private func syncFromNetwork() {
        let liveRounds = network.roundsByGame[currentGameId] ?? []
        let liveGame   = network.games.first { $0.id == currentGameId }
        withAnimation(.easeInOut) {
            roundsCopy = liveRounds
            gameCopy   = liveGame
        }
        deletedRoundIds = []
        editedRounds    = [:]
    }

    // MARK: - Helpers

    private func place(of profile: Profile, in round: Round) -> Int {
        if round.firstProfileId  == profile.id { return 1 }
        if round.secondProfileId == profile.id { return 2 }
        if round.thirdProfileId  == profile.id { return 3 }
        if round.fourthProfileId == profile.id { return 4 }
        if profile.id == -1 || profile.id == -2 || profile.id == -3 || profile.id == -4 {
            if network.profiles.first(where: { $0.id == round.firstProfileId  }) == nil { return 1 }
            if network.profiles.first(where: { $0.id == round.secondProfileId }) == nil { return 2 }
            if network.profiles.first(where: { $0.id == round.thirdProfileId  }) == nil { return 3 }
            if network.profiles.first(where: { $0.id == round.fourthProfileId }) == nil { return 4 }
        }
        return 0
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

    // MARK: - Apply Changes (Done)

    private func applyChanges() async {
        isSaving = true

        let liveRounds = network.roundsByGame[currentGameId] ?? []

    
        for round in roundsCopy {
            guard !deletedRoundIds.contains(round.id) else { continue }
            let live = liveRounds.first(where: { $0.id == round.id })
            guard round != live else { continue } // skip unchanged

            await network.editRound(roundId: round.id, updates: [
                "first_profile_id":   round.firstProfileId  as Any,
                "second_profile_id":  round.secondProfileId as Any,
                "third_profile_id":   round.thirdProfileId  as Any,
                "fourth_profile_id":  round.fourthProfileId as Any,
                "first_bombs":        round.firstBombs,
                "second_bombs":       round.secondBombs,
                "third_bombs":        round.thirdBombs,
                "fourth_bombs":       round.fourthBombs,
                "tichu_points_team1": round.tichuPointsTeam1,
                "tichu_points_team2": round.tichuPointsTeam2,
                "double_win_team1":   round.doubleWinTeam1,
                "double_win_team2":   round.doubleWinTeam2,
                "announced_tichu":    round.announcedTichu,
                "announced_big_tichu": round.announcedBigTichu,
                "announced_pingu":    round.announcedPingu
            ])
        }

        // Delete removed rounds
        for roundId in deletedRoundIds {
            await network.deleteRound(gameId: currentGameId, roundId: roundId)
        }

        await network.reCalculate(gameId: currentGameId)
        await network.fetchGameRounds(gameId: currentGameId)
        await network.fetchGame(gameId: currentGameId)

        isSaving = false
        showEditRoundsSheet = false
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            if !showList {
                if allRounds.count > 0 {
                    roundsList.toolbar { roundsListToolbar }
                } else {
                    Text("No Rounds played yet")
                        .foregroundStyle(.secondary)
                        .toolbar { roundsListToolbar }
                }
            } else {
                emptyView
            }
        }
        .onAppear {
            syncFromNetwork()
        }
        .onChange(of: network.roundsByGame[currentGameId]) {
            syncFromNetwork()
        }
        .onChange(of: network.games.map(\.id)) {
            syncFromNetwork()
        }
        .onChange(of: socket.connected){
            if socket.connected == false{
                showEditRoundsSheet = false
            }
        }
        .safeAreaInset(edge: .top)    { scoreHeader }
        .safeAreaInset(edge: .bottom) { deleteGameButton }
        .alert("Delete this Game?", isPresented: $showDeleteGameAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteGameAlert = false
                showList = false
            }
            Button("Delete", role: .destructive) {
                Task {
                    if let gameId = currentGame?.id {
                        await network.deleteGame(gameId: gameId)
                    }
                    showEditRoundsSheet = false
                }
            }
        } message: {
            Text("This Game will be deleted")
        }
        .overlay {
            if isSaving { ProgressView() }
        }
    }

    // MARK: - Rounds List
    private var roundsList: some View {
        List {
            ForEach(Array(allRounds.enumerated()), id: \.element.id) { index, currentRound in
                let hasExpanded    = expandedRows.contains(index)
                let isWinningRound = winRounds.contains { $0.id == currentRound.id }
                let isLocked       = !isWinningRound

                let sortedTeam1 = sortedTeamProfiles(team1Profiles, in: currentRound)
                let sortedTeam2 = sortedTeamProfiles(team2Profiles, in: currentRound)

                DisclosureGroup(isExpanded: bindingForExpanded(row: index, disabled: isLocked)) {
                    roundDetail(currentRound: currentRound, sortedTeam1: sortedTeam1, sortedTeam2: sortedTeam2)
                } label: {
                    roundLabel(index: index, hasExpanded: hasExpanded, currentRound: currentRound)
                }
                .opacity(isLocked ? 0.5 : 1.0)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation(.easeInOut) {
                            deleteRoundLocally(roundId: currentRound.id)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    if !isLocked {
                        editButton(for: index)
                    }
                }
            }

            TipView(listSwipeTip).tipBackground(.clear)

            if allRounds.count != winRounds.count {
                Section {
                    Text("\(allRounds.count - winRounds.count) Rounds are not being counted. This happens because a Round was edited in such a way, that the winner already won after Round \(winRounds.count).")
                }
                .listRowBackground(Color.clear)
                .foregroundStyle(.secondary)
            }
        }
        .task {
            do { try Tips.configure() } catch {
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showAddRoundSheet) {
            AddRoundSheetLocalView(
                showAddRoundsSheet: $showAddRoundSheet,
                rounds: $roundsCopy,
                game: Binding(get: { gameCopy! }, set: { gameCopy = $0 }),
                profiles: profiles,
                editMode: true,
                roundIndex: editingRoundIndex + 1,
                editingRound: allRounds[safe: editingRoundIndex]
            )
        }
        .zIndex(0)
        .listSectionSpacing(0)
        .animation(.spring(duration: 0.25), value: expandedRows)
        .animation(.easeInOut(duration: 0.25), value: showList)
        .navigationTitle("Edit Game")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 20)
    }

    // MARK: - Local Delete

    private func deleteRoundLocally(roundId: Int) {
        deletedRoundIds.insert(roundId)
        roundsCopy.removeAll { $0.id == roundId }
    }

    // MARK: - UI Helpers

    @ViewBuilder
    private func editButton(for index: Int) -> some View {
        Button {
            editingRoundIndex = index
            showAddRoundSheet = true
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .animation(.easeInOut, value: showAddRoundSheet)
        .tint(.accentColor)
    }

    // MARK: - Round Label
    private func roundLabel(index: Int, hasExpanded: Bool, currentRound: Round) -> some View {
        HStack {
            Text("Round \(index + 1)")
                .fontWeight(.bold)
                .font(.title3)
                .padding(10)
            Spacer()
            if !hasExpanded {
                Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)").fontWeight(.bold)
                Text("vs").fontWeight(.bold)
                Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)").fontWeight(.bold)
            }
        }
    }

    // MARK: - Round Detail
    private func roundDetail(currentRound: Round, sortedTeam1: [Profile], sortedTeam2: [Profile]) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Team 1").fontWeight(.bold).foregroundStyle(Color.accentColor)
                    Spacer()
                    Text("\(currentRound.tichuPointsTeam1 + currentRound.roundPointsTeam1)").fontWeight(.bold).foregroundStyle(Color.accentColor)
                }
                .padding(.top)
                .padding(.horizontal)

                playerRows(players: sortedTeam1, round: currentRound, teamProfileIds: (currentGame?.team1Player1Id, currentGame?.team1Player2Id))

                HStack {
                    Text("Team 2").fontWeight(.bold)
                    Spacer()
                    Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)").fontWeight(.bold)
                }
                .padding(.top)
                .padding(.horizontal)

                playerRows(players: sortedTeam2, round: currentRound, teamProfileIds: (currentGame?.team2Player1Id, currentGame?.team2Player2Id))
            }
            Spacer()
        }
        .padding(.top, -20)
        .padding(.leading, -20)
        .padding(.trailing, 5)
    }

    // MARK: - Player Rows
    private func playerRows(players: [Profile], round: Round, teamProfileIds: (Int?, Int?)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(players, id: \.id) { player in
                let playerPlace = place(of: player, in: round)
                let isFirst     = round.firstProfileId == player.id

                let firstId  = round.firstProfileId
                let secondId = round.secondProfileId
                let teamIds  = [teamProfileIds.0, teamProfileIds.1]
                let isDoubleWin = (firstId != nil && secondId != nil) &&
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
                    announcementView(tichu: tichu, bigTichu: bigTichu, pingu: pingu, isFirst: isFirst, bomb: bomb)
                    bombView(bomb: bomb)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemGroupedBackground)))
    }

    // MARK: - Announcement View
    private func announcementView(tichu: Bool, bigTichu: Bool, pingu: Bool, isFirst: Bool, bomb: Int) -> some View {
        let offset: CGFloat = bomb > 0 ? 40 : 0
        let succeeded = isFirst

        return Group {
            if tichu {
                announcementLabel(text: "Tichu", succeeded: succeeded, offset: offset)
            } else if bigTichu {
                announcementLabel(text: "Big Tichu", succeeded: succeeded, offset: offset)
            } else if pingu {
                announcementLabel(text: "Pingu", succeeded: succeeded, offset: offset)
            }
        }
    }

    private func announcementLabel(text: String, succeeded: Bool, offset: CGFloat) -> some View {
        HStack {
            Image(systemName: succeeded ? "checkmark" : "xmark")
            Text(text)
        }
        .foregroundStyle(succeeded ? .green : .red)
        .opacity(colorScheme == .dark ? 0.66 : 1)
        .offset(x: offset)
    }

    // MARK: - Empty View
    private var emptyView: some View {
        Text(" ")
            .navigationTitle("Edit Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { emptyViewToolbar }
    }

    // MARK: - Score Header
    private var scoreHeader: some View {
        HStack {
            Text("Team 1: \(copyPointsTeam1)").foregroundStyle(Color.accentColor)
            Spacer()
            Text("Team 2: \(copyPointsTeam2)")
        }
        .fontWeight(.bold)
        .font(.title2)
        .padding(.horizontal, 30)
        .padding(.top, 80)
    }

    // MARK: - Delete Game Button
    private var deleteGameButton: some View {
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

    // MARK: - Toolbars
    @ToolbarContentBuilder
    private var roundsListToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark") {
                showEditRoundsSheet = false
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", systemImage: "checkmark") {
                Task { await applyChanges() }
            }.disabled(socket.connected == false)
        }
    }

    @ToolbarContentBuilder
    private var emptyViewToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark") { showEditRoundsSheet = false }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", systemImage: "checkmark") { showEditRoundsSheet = false }
        }
    }
}

// MARK: - Safe subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
