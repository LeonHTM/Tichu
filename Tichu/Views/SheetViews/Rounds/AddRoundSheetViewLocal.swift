//
//  AddRoundSheetViewLocal.swift
//  Tichu
//
//  Created by Leon on 02.06.2026.
//


import SwiftUI

struct AddRoundSheetLocalView: View {

    // MARK: - Storage
    @AppStorage("dragMode") var dragMode: Bool = false

    // MARK: - Bindings
    @Binding var showAddRoundsSheet: Bool
    @Binding var rounds: [Round]
    @Binding var game: Game

    // MARK: - Dependencies
    let profiles: [Profile]

    // MARK: - Props
    var editMode: Bool
    let roundIndex: Int?
    var editingRound: Round?

    // MARK: - State
    @State private var hasAnnouncedPlayer1: CanAnnounce = .none
    @State private var hasAnnouncedPlayer2: CanAnnounce = .none
    @State private var hasAnnouncedPlayer3: CanAnnounce = .none
    @State private var hasAnnouncedPlayer4: CanAnnounce = .none
    @State private var players: [Profile?] = []
    @State private var counter: Int = 0
    @State private var hasPushedList: [Bool] = [false, false, false, false]
    @State private var rankingList: [Int] = [0, 0, 0, 0]

    @State private var firstProfileId: Int? = nil
    @State private var secondProfileId: Int? = nil
    @State private var thirdProfileId: Int? = nil
    @State private var fourthProfileId: Int? = nil
    @State private var firstBombs: Int = 0
    @State private var secondBombs: Int = 0
    @State private var thirdBombs: Int = 0
    @State private var fourthBombs: Int = 0
    @State private var tichuPointsTeam1: Int = 50
    @State private var tichuPointsTeam2: Int = 50
    @State private var announcedTichu: [Int] = []
    @State private var announcedBigTichu: [Int] = []
    @State private var announcedPingu: [Int] = []

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Resolved Players
    private var player1: Profile? { profiles.first { $0.id == game.team1Player1Id } }
    private var player2: Profile? { profiles.first { $0.id == game.team1Player2Id } }
    private var player3: Profile? { profiles.first { $0.id == game.team2Player1Id } }
    private var player4: Profile? { profiles.first { $0.id == game.team2Player2Id } }

    private var team1Ids: [Int] { [game.team1Player1Id, game.team1Player2Id].compactMap { $0 } }
    private var team2Ids: [Int] { [game.team2Player1Id, game.team2Player2Id].compactMap { $0 } }

    // MARK: - Computed

    private var hasDoubleWinTeam1: Bool {
        guard let f = firstProfileId, let s = secondProfileId else { return false }
        return team1Ids.contains(f) && team1Ids.contains(s)
    }

    private var hasDoubleWinTeam2: Bool {
        guard let f = firstProfileId, let s = secondProfileId else { return false }
        return team2Ids.contains(f) && team2Ids.contains(s)
    }

    private var displayTeam1Points: Int {
        if hasDoubleWinTeam1 { return 100 }
        if hasDoubleWinTeam2 { return 0 }
        return tichuPointsTeam1
    }

    private var displayTeam2Points: Int {
        if hasDoubleWinTeam2 { return 100 }
        if hasDoubleWinTeam1 { return 0 }
        return tichuPointsTeam2
    }

    // MARK: - Team Helpers

    private func isTeam1(_ player: Profile?) -> Bool {
        guard let player else { return false }
        return team1Ids.contains(player.id)
    }

    private func isTeam2(_ player: Profile?) -> Bool {
        guard let player else { return false }
        return team2Ids.contains(player.id)
    }

    private func isGolden(index: Int) -> Bool {
        guard index < 2, players.count >= 2,
              let first = players[0], let second = players[1] else { return false }
        return (isTeam1(first) && isTeam1(second)) || (isTeam2(first) && isTeam2(second))
    }

    private func isGolden2(index: Int) -> Bool {
        guard let firstIndex = rankingList.firstIndex(of: 1),
              let secondIndex = rankingList.firstIndex(of: 2),
              index == firstIndex || index == secondIndex,
              let first = players[firstIndex], let second = players[secondIndex] else { return false }
        return (isTeam1(first) && isTeam1(second)) || (isTeam2(first) && isTeam2(second))
    }

    // MARK: - Announcement Helpers

    func announcement(for player: Profile?) -> CanAnnounce {
        guard let player else { return .none }
        if announcedBigTichu.contains(player.id) { return .bigTichu }
        if announcedTichu.contains(player.id) { return .tichu }
        if announcedPingu.contains(player.id) { return .pingu }
        return .none
    }

    func updateAnnouncement(playerId: Int, state: CanAnnounce) {
        announcedTichu.removeAll { $0 == playerId }
        announcedBigTichu.removeAll { $0 == playerId }
        announcedPingu.removeAll { $0 == playerId }
        switch state {
        case .tichu:    announcedTichu.append(playerId)
        case .bigTichu: announcedBigTichu.append(playerId)
        case .pingu:    announcedPingu.append(playerId)
        case .none:     break
        }
    }

    // MARK: - Round Logic

    func move(from source: IndexSet, to destination: Int) {
        players.move(fromOffsets: source, toOffset: destination)
    }

    private func buildRankingList() -> [Int] {
        let orderIds: [Int?] = [firstProfileId, secondProfileId, thirdProfileId, fourthProfileId]
        return players.map { player in
            guard let player else { return 0 }
            if let idx = orderIds.firstIndex(where: { $0 == player.id }) { return idx + 1 }
            return 0
        }
    }

    private func applyDoubleWin() {
        if hasDoubleWinTeam1 {
            tichuPointsTeam1 = 100
            tichuPointsTeam2 = 0
        } else if hasDoubleWinTeam2 {
            tichuPointsTeam1 = 0
            tichuPointsTeam2 = 100
        }
    }

    func saveRound() {
        if dragMode {
            firstProfileId  = players[0]?.id
            secondProfileId = players[1]?.id
            thirdProfileId  = players[2]?.id
            fourthProfileId = players[3]?.id
        }
        if let p1 = player1 { updateAnnouncement(playerId: p1.id, state: hasAnnouncedPlayer1) }
        if let p2 = player2 { updateAnnouncement(playerId: p2.id, state: hasAnnouncedPlayer2) }
        if let p3 = player3 { updateAnnouncement(playerId: p3.id, state: hasAnnouncedPlayer3) }
        if let p4 = player4 { updateAnnouncement(playerId: p4.id, state: hasAnnouncedPlayer4) }
        applyDoubleWin()

        if editMode, let round = editingRound {
            // Apply edits to the local rounds binding
            if let idx = rounds.firstIndex(where: { $0.id == round.id }) {
                rounds[idx].firstProfileId   = firstProfileId
                rounds[idx].secondProfileId  = secondProfileId
                rounds[idx].thirdProfileId   = thirdProfileId
                rounds[idx].fourthProfileId  = fourthProfileId
                rounds[idx].firstBombs       = firstBombs
                rounds[idx].secondBombs      = secondBombs
                rounds[idx].thirdBombs       = thirdBombs
                rounds[idx].fourthBombs      = fourthBombs
                rounds[idx].tichuPointsTeam1 = tichuPointsTeam1
                rounds[idx].tichuPointsTeam2 = tichuPointsTeam2
                rounds[idx].doubleWinTeam1   = hasDoubleWinTeam1
                rounds[idx].doubleWinTeam2   = hasDoubleWinTeam2
                rounds[idx].announcedTichu    = announcedTichu
                rounds[idx].announcedBigTichu = announcedBigTichu
                rounds[idx].announcedPingu    = announcedPingu
            }
        } else {
            // Append a new round locally
            let nextOrder = (rounds.map { $0.roundOrder }.max() ?? 0) + 1
            let newRound = Round(
                id: Int.random(in: -999_999 ... -1), // temporary negative ID; server will assign real one
                gameId: game.id,
                roundOrder: nextOrder,
                firstProfileId: firstProfileId,
                secondProfileId: secondProfileId,
                thirdProfileId: thirdProfileId,
                fourthProfileId: fourthProfileId,
                firstBombs: firstBombs,
                secondBombs: secondBombs,
                thirdBombs: thirdBombs,
                fourthBombs: fourthBombs,
                tichuPointsTeam1: tichuPointsTeam1,
                tichuPointsTeam2: tichuPointsTeam2,
                roundPointsTeam1: 0,
                roundPointsTeam2: 0,
                doubleWinTeam1: hasDoubleWinTeam1,
                doubleWinTeam2: hasDoubleWinTeam2,
                boolWinRound: true,
                announcedTichu: announcedTichu,
                announcedBigTichu: announcedBigTichu,
                announcedPingu: announcedPingu
            )
            rounds.append(newRound)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    teamContainersRow
                    placementSection
                    pointsSection
                }
                .navigationTitle(editMode ? "Edit Round \(roundIndex ?? -69420)" : "Add Round")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") { showAddRoundsSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            saveRound()
                            showAddRoundsSheet = false
                        }
                        .disabled(dragMode ? false : !rankingList.allSatisfy({ $0 != 0 }))
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .onAppear {
                players = [player1, player2, player3, player4]

                if editMode, let round = editingRound {
                    firstProfileId   = round.firstProfileId
                    secondProfileId  = round.secondProfileId
                    thirdProfileId   = round.thirdProfileId
                    fourthProfileId  = round.fourthProfileId
                    firstBombs       = round.firstBombs
                    secondBombs      = round.secondBombs
                    thirdBombs       = round.thirdBombs
                    fourthBombs      = round.fourthBombs
                    tichuPointsTeam1 = round.tichuPointsTeam1
                    tichuPointsTeam2 = round.tichuPointsTeam2
                    announcedTichu    = round.announcedTichu
                    announcedBigTichu = round.announcedBigTichu
                    announcedPingu    = round.announcedPingu
                    hasPushedList = [true, true, true, true]
                    rankingList = buildRankingList()
                    counter = rankingList.filter { $0 != 0 }.count
                }

                hasAnnouncedPlayer1 = announcement(for: player1)
                hasAnnouncedPlayer2 = announcement(for: player2)
                hasAnnouncedPlayer3 = announcement(for: player3)
                hasAnnouncedPlayer4 = announcement(for: player4)
            }
        }
    }

    // MARK: - Team Containers Row
    private var teamContainersRow: some View {
        HStack {
            GlassEffectContainer {
                VStack(alignment: .leading) {
                    Text("Team 1").font(.title2).fontWeight(.bold).foregroundStyle(Color.accentColor)
                    VStack {
                        PlayerContainer(
                            player: player1 ?? Profile(),
                            teamIds: team1Ids,
                            allowPingus: game.allowPingus,
                            isTeam1: true,
                            hasAnnounced: $hasAnnouncedPlayer1,
                            bombNumber: $firstBombs
                        )
                        PlayerContainer(
                            player: player2 ?? Profile(),
                            teamIds: team1Ids,
                            allowPingus: game.allowPingus,
                            isTeam1: true,
                            hasAnnounced: $hasAnnouncedPlayer2,
                            bombNumber: $secondBombs
                        )
                    }
                    .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                }
            }

            VStack(alignment: .leading) {
                Text("Team 2").font(.title2).fontWeight(.bold)
                VStack {
                    PlayerContainer(
                        player: player3 ?? Profile(),
                        teamIds: team2Ids,
                        allowPingus: game.allowPingus,
                        isTeam1: false,
                        hasAnnounced: $hasAnnouncedPlayer3,
                        bombNumber: $thirdBombs
                    )
                    PlayerContainer(
                        player: player4 ?? Profile(),
                        teamIds: team2Ids,
                        allowPingus: game.allowPingus,
                        isTeam1: false,
                        hasAnnounced: $hasAnnouncedPlayer4,
                        bombNumber: $fourthBombs
                    )
                }
                .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
            }
        }
    }

    // MARK: - Placement Section
    private var placementSection: some View {
        VStack {
            HStack {
                Text("Placement").font(.title2).fontWeight(.bold).padding(.leading, 20)
                Spacer()
            }
            .zIndex(1)

            if dragMode {
                dragPlacementList
            } else {
                tapPlacementList
            }
        }
    }

    // MARK: - Drag Placement List
    private var dragPlacementList: some View {
        List {
            ForEach(Array(players.enumerated()), id: \.element?.id) { index, player in
                let golden = isGolden(index: index)
                HStack {
                    Text("\(index + 1).").fontWeight(.bold).foregroundStyle(golden ? Color.accentColor : Color.primary)
                    Text(player?.name ?? "Unknown")
                    Spacer()
                }
            }
            .onMove(perform: move)
        }
        .environment(\.editMode, .constant(.active))
        .frame(height: 250)
        .scrollDisabled(true)
        .padding(.top, -40)
        .zIndex(0)
    }

    // MARK: - Tap Placement List
    private var tapPlacementList: some View {
        List {
            ForEach(Array(players.enumerated()), id: \.element?.id) { index, player in
                let golden = isGolden2(index: index)
                HStack {
                    Button {
                        if hasPushedList[index] == false {
                            counter += 1
                            rankingList[index] = counter
                            hasPushedList[index] = true
                            if rankingList.allSatisfy({ $0 != 0 }) {
                                withAnimation(.easeInOut) {
                                    if let i1 = rankingList.firstIndex(of: 1) { firstProfileId  = players[i1]?.id }
                                    if let i2 = rankingList.firstIndex(of: 2) { secondProfileId = players[i2]?.id }
                                    if let i3 = rankingList.firstIndex(of: 3) { thirdProfileId  = players[i3]?.id }
                                    if let i4 = rankingList.firstIndex(of: 4) { fourthProfileId = players[i4]?.id }
                                }
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                counter = 0
                                rankingList = [0, 0, 0, 0]
                                hasPushedList = [false, false, false, false]
                                firstProfileId  = nil
                                secondProfileId = nil
                                thirdProfileId  = nil
                                fourthProfileId = nil
                            }
                        }
                    } label: {
                        HStack {
                            Text("\(rankingList[index]).").fontWeight(.bold)
                                .foregroundStyle(rankingList[index] == 0 ? Color.secondary : golden ? Color.green : Color.primary)
                            Text(player?.name ?? "Unknown")
                            Spacer()
                        }
                    }
                    .sensoryFeedback(.selection, trigger: counter)
                    .foregroundStyle(Color.primary)
                }
            }
        }
        .frame(height: 250)
        .scrollDisabled(true)
        .padding(.top, -40)
        .zIndex(0)
    }

    // MARK: - Points Section
    private var pointsSection: some View {
        VStack {
            HStack {
                Text("Points 1").font(.title2).fontWeight(.bold).foregroundStyle(Color.accentColor)
                Spacer()
                Text("Points 2").font(.title2).fontWeight(.bold)
            }
            .padding(.trailing, 20)

            VStack(alignment: .leading) {
                HStack {
                    Text("\(displayTeam1Points)").font(.title2).fontWeight(.bold).foregroundStyle(Color.accentColor)
                    if hasDoubleWinTeam1 || hasDoubleWinTeam2 {
                        Spacer()
                        Text("Double Win!").foregroundStyle(Color.green)
                    }
                    Spacer()
                    Text("\(displayTeam2Points)").font(.title2).fontWeight(.bold)
                }

                Slider(
                    value: Binding(
                        get: {
                            if hasDoubleWinTeam1 { return 100 }
                            else if hasDoubleWinTeam2 { return 0 }
                            return Double(tichuPointsTeam1)
                        },
                        set: { newValue in
                            guard !hasDoubleWinTeam1 else { return }
                            tichuPointsTeam1 = Int(newValue)
                            tichuPointsTeam2 = 100 - Int(newValue)
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
}
