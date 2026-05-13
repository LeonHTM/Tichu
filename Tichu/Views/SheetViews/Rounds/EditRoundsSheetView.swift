//
//  EditRoundsSheetView.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI
import TipKit
internal import Combine

struct EditRoundsSheetView: View {

    // MARK: - Bindings
    @Binding var showEditRoundsSheet: Bool
    @Binding var currentGame: tichuGame

    // MARK: - State
    @State private var currentGameCopy: tichuGame = tichuGame()
    @State private var currentRound = Round()
    @State private var expandedRows: Set<Int> = []
    @State private var showDeleteGameAlert: Bool = false
    @State private var showAddRoundSheet: Bool = false
    @State private var showList: Bool = false
    @State private var editingRoundIndex: Int = 0
    var listSwipeTip = ListSwipeTip()

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Helpers
    private func placement(player: Profile, in round: Round) -> Int {
        if round.first?.id == player.id { return 1 }
        if round.second?.id == player.id { return 2 }
        if round.third?.id == player.id { return 3 }
        if round.fourth?.id == player.id { return 4 }
        return 999
    }

    private func sortedTeam(team: Team, in round: Round) -> [Profile] {
        team.list.sorted { placement(player: $0, in: round) < placement(player: $1, in: round) }
    }

    private func bombCounter(player: Profile, round: Round) -> Int {
        if player.id == round.first?.id { return round.firstBombs }
        else if player.id == round.second?.id { return round.secondBombs }
        else if player.id == round.third?.id { return round.thirdBombs }
        else if player.id == round.fourth?.id { return round.fourthBombs }
        else { return 999 }
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
    
    let timer = Timer.publish(
            every: 5,      // interval in seconds
            on: .main,
            in: .common
        ).autoconnect()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            if !showList {
                roundsList
            } else {
                emptyView
            }
        }
        .onAppear { currentGameCopy = currentGame }
        .safeAreaInset(edge: .top) { scoreHeader }
        .safeAreaInset(edge: .bottom) { deleteGameButton }
        .alert("Delete this Game?", isPresented: $showDeleteGameAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteGameAlert = false
                showList = false
            }
            Button("Delete", role: .destructive) {
                showEditRoundsSheet = false
                showList = false
                DispatchQueue.main.async { currentGame = tichuGame() }
            }
        } message: {
            Text("This Game will be deleted")
        }
    }

    // MARK: - Rounds List
    private var roundsList: some View {
        
            
        List {
            
            ForEach(Array($currentGameCopy.Rounds), id: \.id) { $currentRound in
                let index = currentGameCopy.Rounds.firstIndex(where: { $0.id == currentRound.id }) ?? 0
                let hasExpanded = expandedRows.contains(index)
                let isWinningRound = currentGameCopy.winRounds.contains { $0.id == currentRound.id }
                let isLocked = !isWinningRound
                
                let sortedTeam1 = sortedTeam(team: currentGameCopy.team1 ?? Team(list: []), in: currentRound)
                let sortedTeam2 = sortedTeam(team: currentGameCopy.team2 ?? Team(list: []), in: currentRound)
                
                DisclosureGroup(isExpanded: bindingForExpanded(row: index, disabled: isLocked)) {
                    roundDetail(currentRound: currentRound, sortedTeam1: sortedTeam1, sortedTeam2: sortedTeam2)
                } label: {
                    roundLabel(index: index, hasExpanded: hasExpanded, currentRound: currentRound)
                }
                .opacity(isLocked ? 0.5 : 1.0)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation(.easeInOut) {
                            if currentGameCopy.Rounds.count > 1 {
                                currentGameCopy.Rounds.remove(at: index)
                                currentGameCopy.reCount()
                            } else {
                                showDeleteGameAlert = true
                                DispatchQueue.main.async { showList = true }
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    if !isLocked {
                        Button {
                            withAnimation(.easeInOut) {
                                editingRoundIndex = index
                                showAddRoundSheet = true
                            }
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.accentColor)
                        
                    }
                }
                
            }
            TipView(listSwipeTip).tipBackground(.clear)
            
            
            if currentGameCopy.Rounds.count != currentGameCopy.winRounds.count {
                Section {
                    Text("\(currentGameCopy.Rounds.count - currentGameCopy.winRounds.count) Rounds are not being counted. This happens because a Round was edited in such a way, that \(currentGameCopy.winner?.name ?? "Unknown") already won after Round \(currentGameCopy.winRounds.count).")
                }
                .listRowBackground(Color.clear)
                .foregroundStyle(.secondary)
                
            }
            
        }
            
    
        
        .task {
            // Configure and load your tips at app launch.
            do {
                try Tips.resetDatastore()
                try Tips.configure()
            }
            catch {
                // Handle TipKit errors
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showAddRoundSheet, onDismiss: { currentRound = Round() }) {
            let roundBinding = Binding<Round>(
                get: { currentGameCopy.Rounds[editingRoundIndex] },
                set: { currentGameCopy.Rounds[editingRoundIndex] = $0 }
            )
            AddRoundSheetView(
                showAddRoundsSheet: $showAddRoundSheet,
                currentGame: $currentGameCopy,
                currentRound: roundBinding,
                editMode: true,
                roundIndex: editingRoundIndex + 1
            )
        }
        .id(editingRoundIndex)
        .zIndex(0)
        .listSectionSpacing(0)
        .animation(.spring(duration: 0.25), value: expandedRows)
        .animation(.easeInOut(duration: 0.25), value: showList)
        .navigationTitle("Edit Game")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { roundsListToolbar }
    }

    // MARK: - Round Label
    private func roundLabel(index: Int, hasExpanded: Bool, currentRound: Round) -> some View {
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

                playerRows(players: sortedTeam1, round: currentRound, teamPlayers: (currentGameCopy.player1, currentGameCopy.player2))

                HStack {
                    Text("Team 2").fontWeight(.bold)
                    Spacer()
                    Text("\(currentRound.tichuPointsTeam2 + currentRound.roundPointsTeam2)").fontWeight(.bold)
                }
                .padding(.top)
                .padding(.horizontal)

                playerRows(players: sortedTeam2, round: currentRound, teamPlayers: (currentGameCopy.player3, currentGameCopy.player4))
            }
            Spacer()
        }
        .padding(.top, -20)
        .padding(.leading, -20)
        .padding(.trailing, 5)
    }

    // MARK: - Player Rows
    private func playerRows(players: [Profile], round: Round, teamPlayers: (Profile?, Profile?)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(players, id: \.id) { player in
                let place = placement(player: player, in: round)
                let isFirst = round.first?.id == player.id
                let isFirstIsA = round.first?.id == teamPlayers.0?.id
                let isFirstIsB = round.first?.id == teamPlayers.1?.id
                let isSecondIsA = round.second?.id == teamPlayers.0?.id
                let isSecondIsB = round.second?.id == teamPlayers.1?.id
                let placeColor: Color = (place == 1 && isSecondIsA || place == 1 && isSecondIsB || place == 2 && isFirstIsA || place == 2 && isFirstIsB)
                    ? .green.opacity(colorScheme == .dark ? 0.66 : 1) : .primary

                let tichu = round.hasAnnouncedTichu.contains(player)
                let bigTichu = round.hasAnnouncedBigTichu.contains(player)
                let pingu = round.hasAnnouncedPingu.contains(player)
                let bomb = bombCounter(player: player, round: round)

                HStack {
                    Text("\(place).").fontWeight(.bold).foregroundStyle(placeColor)
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

    // MARK: - Bomb View
    private func bombView(bomb: Int) -> some View {
        Group {
            if bomb > 0 {
                HStack {
                    Image(systemName: "flame").offset(x: 47)
                    Text("\(bomb)").font(.system(size: 12)).offset(x: 37, y: 7)
                }
            }
        }
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
            Text("Team 1:").foregroundStyle(Color.accentColor)
            Text("\(currentGameCopy.currentPointsTeam1)").foregroundStyle(Color.accentColor)
            Spacer()
            Text("Team 2:")
            Text("\(currentGameCopy.currentPointsTeam2)")
        }
        .fontWeight(.bold)
        .font(.title2)
        .padding(.horizontal, 30)
        .padding(.top, 65)
        .padding(.bottom, 20)
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
            Button("Cancel", systemImage: "xmark") { showEditRoundsSheet = false }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", systemImage: "checkmark") {
                currentGame = currentGameCopy
                currentGame.reCount()
                showEditRoundsSheet = false
            }
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

#Preview {
    EditRoundsSheetView(
        showEditRoundsSheet: .constant(true),
        currentGame: .constant(exampleGame)
    )
}

