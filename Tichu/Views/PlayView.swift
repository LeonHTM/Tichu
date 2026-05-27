//
//  PlayView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct PlayView: View {

    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    @AppStorage("userImageData") var userImageData: Data?
    @AppStorage("userName") var userName: String = "Storage - Unknown"
    @AppStorage("userElo") var userElo: Int = 404

    // MARK: - Input
    let fetchTrigger: Int

    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared

    // MARK: - State
    @State private var showAddPlayersSheet2: Bool = false
    @State private var showAddPlayersSheet3: Bool = false
    @State private var showAddPlayersSheet4: Bool = false
    @State private var showEditRoundsSheet: Bool = false
    @State private var showAddRoundSheet: Bool = false
    @State private var showDebugSheetView: Bool = false
    @State private var showGameOverSheet: Bool = false

    @State private var showPlayers: Bool = true
    @State private var showFriends: Bool = true

    @State private var currentGame: Game? = nil

    @State private var revanche: Bool = false

    @State private var player1Id: Int?
    @State private var player2Id: Int?
    @State private var player3Id: Int?
    @State private var player4Id: Int?

    @State private var target: Int = 1000
    @State private var allowPingus: Bool = true

    @FocusState private var targetFieldFocused: Bool
    
    
    
    // MARK: - Computed

    private var player1: Profile? {
        network.profiles.first { $0.id == userId }
    }

    private func profile(for id: Int?) -> Profile? {
        guard let id else { return nil }
        return network.profiles.first { $0.id == id }
    }

    private var isGameReady: Bool {
        player1 != nil && player2Id != nil && player3Id != nil && player4Id != nil
    }

    private var gameDone: Bool {
        guard let game = currentGame else { return false }
        if game.currentPointsTeam1 >= game.target && game.currentPointsTeam1 > game.currentPointsTeam2 { return true }
        if game.currentPointsTeam2 >= game.target && game.currentPointsTeam2 > game.currentPointsTeam1 { return true }
        return false
    }

    private var isRated: Bool {
        let ids = [userId, player2Id, player3Id, player4Id].compactMap { $0 }
        guard ids.count == 4 else { return false }
        return ids.allSatisfy { id in
            network.profiles.first { $0.id == id }?.elo != nil
        }
    }

    private var currentPointsTeam1: Int { currentGame?.currentPointsTeam1 ?? -69402 }
    private var currentPointsTeam2: Int { currentGame?.currentPointsTeam2 ?? 0 }

    // MARK: - Methods

    private func startGame() {
        if currentGame == nil{
            Task {
                let game = await network.addGame(
                    target: target,
                    allowPingus: allowPingus,
                    team1Player1Id: userId,
                    team1Player2Id: player2Id,
                    team2Player1Id: player3Id,
                    team2Player2Id: player4Id
                )
                await MainActor.run {
                    currentGame = game
                }
            }
        }
    }

    private func resetGame() {
        withAnimation(.easeInOut){
            currentGame = nil
            player2Id = nil
            player3Id = nil
            player4Id = nil
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    team1Header
                    team1Players
                    centerSpacer
                    team2Header
                    team2Players
                }
                    
                
                .refreshable {
                    await network.fetch(isLoading: .constant(false))
                }
                .onChange(of:network.games){
                    if currentGame != nil{
                        print("brakka5000")
                        guard let id = currentGame?.id else { return }
                        currentGame = network.games.first(where: { $0.id == id })
                    }
                    
                }
                
                .onChange(of: fetchTrigger) {
                    let openGames = network.games.filter { $0.winner == nil }
                    print("OPEN GAMES: \(openGames.count)")
                    print("GAMES: \(network.games.count)")
                    //print("CLOSED GAMES: \(network.games.filter($0.winner != nil).count)")
                    if openGames.count == 1 {
                        withAnimation(.easeInOut){
                            currentGame = openGames.first
                            player1Id = currentGame?.team1Player1Id
                            player2Id = currentGame?.team1Player2Id
                            player3Id = currentGame?.team2Player1Id
                            player4Id = currentGame?.team2Player2Id
                            Task{
                                await network.fetchGameRounds(gameId: currentGame!.id)
                            }
                        }
                    }
                }
                .onChange(of: isGameReady) {
                    if isGameReady {
                        startGame()
                    }
                }
                .onChange(of: socket.connected) {
                    if !socket.connected {
                        showFriends = false
                        showPlayers = false
                    } else {
                        showFriends = true
                        showPlayers = true
                    }
                }
                .onChange(of: network.games.map(\.id)) {
                    guard let id = currentGame?.id else { return }

                    if network.games.first(where: { $0.id == id }) == nil {
                        showEditRoundsSheet = false
                        resetGame()
                    }
                        
                    
                }
                .onChange(of: gameDone) {
                    if gameDone { showGameOverSheet = true }
                }
                .sheet(isPresented: $showGameOverSheet, onDismiss: {
                    if revanche {
                        guard let game = currentGame else { return }
                        let p1 = game.team1Player1Id
                        let p2 = game.team1Player2Id
                        let p3 = game.team2Player1Id
                        let p4 = game.team2Player2Id
                        Task {
                            let newGame = await network.addGame(
                                target: game.target,
                                allowPingus: game.allowPingus,
                                team1Player1Id: p1,
                                team1Player2Id: p2,
                                team2Player1Id: p3,
                                team2Player2Id: p4
                            )
                            await MainActor.run {
                                currentGame = newGame
                                revanche = false
                            }
                        }
                    } else {
                        resetGame()
                    }
                }) {
                    if let game = currentGame {
                        GameSummarySheetView(
                            showGameOverViewSheetView: $showGameOverSheet,
                            currentGame: Binding(
                                get: { game },
                                set: { currentGame = $0 }
                            ),
                            revanche: $revanche,
                            profiles: network.profiles,
                            network: network,
                            showRevancheButton: true,
                            HistoryMode: false
                        )
                        .presentationDetents([.medium, .large])
                    }
                }
                .scrollContentBackground(.hidden)
                .background(alignment: .center) { vsBackground }
                .edgesIgnoringSafeArea(.all)
                .background(Color(uiColor: .systemGroupedBackground))
                .listSectionSpacing(0)
                .navigationTitle("Play")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem {
                        Button { showDebugSheetView = true } label: {
                            Image(systemName: "ant").foregroundStyle(socket.connected ? Color.green : Color.red)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationProfileImage()
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { targetFieldFocused = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showDebugSheetView) {
            DebugSheetView(
                currentGame: Binding(
                    get: { currentGame ?? Game(id: 0, date: Date(), target: 1000, allowPingus: true, currentPointsTeam1: 0, currentPointsTeam2: 0) },
                    set: { currentGame = $0 }
                ),
                showDebugSheetView: $showDebugSheetView
            )
        }
        .safeAreaInset(edge: .bottom) {
            if isGameReady {
                gameReadyBottomBar
            } else {
                gameSettingsBottomBar
            }
        }
    }

    // MARK: - Team 1 Header
    private var team1Header: some View {
        Section {
            HStack {
                
                Text("Team 1")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                Spacer()
                if isGameReady {
                    Text("\(currentPointsTeam1)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            
            }
            .listRowBackground(Color.clear)
        }
        .padding(.top, 65)
    }

    // MARK: - Team 1 Players
    private var team1Players: some View {
        Section {
            HStack {
                if let p1Id = player1Id, let p1 = profile(for: p1Id) {
                    HStack {
                        ProfileImage(data: network.profileImages[p1Id], size: 44)
                        Text(p1.name ?? "Unknown").fontWeight(.bold).foregroundStyle(Color.accentColor)
                        Spacer()
                        if let elo = p1.elo {
                            Text("Ranking: \(elo)").foregroundStyle(.secondary).font(.system(size: 16))
                        } else {
                            Text("Download Tichu App to get ranked").foregroundStyle(.secondary).font(.system(size: 16))
                        }
                    }
                } else {
                    ProfileImage(data: userImageData, size: 44)
                    VStack(alignment: .leading) {
                        Text(player1?.name ?? userName)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentColor)
                    }
                    Spacer()
                    if let ranking = player1?.elo {
                        Text("Ranking: \(ranking)")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    } else {
                        ProgressView()
                    }
                }
            }

            if let p2Id = player2Id, let p2 = profile(for: p2Id) {
                HStack {
                    ProfileImage(data: network.profileImages[p2Id], size: 44)
                    Text(p2.name ?? "Unknown").fontWeight(.bold).foregroundStyle(Color.accentColor)
                    Spacer()
                    if let elo = p2.elo {
                        Text("Ranking: \(elo)").foregroundStyle(.secondary).font(.system(size: 16))
                    } else {
                        Text("Download Tichu App to get ranked").foregroundStyle(.secondary).font(.system(size: 16))
                    }
                }
            } else {
                addPlayerRow(label: "Add Player 2", action: { showAddPlayersSheet2 = true })
                    .sheet(isPresented: $showAddPlayersSheet2) {
                        AddPlayersSheetView(
                            showAddPlayersSheet: $showAddPlayersSheet2,
                            addPlayerId: $player2Id,
                            alreadyAdded: [player3Id, player4Id].compactMap { $0 },
                            showGuest: .constant(true),
                            showPlayers: $showPlayers,
                            showFriends: $showFriends,
                            guestIndex: 2
                        )
                        .presentationDetents([.medium, .large])
                    }
            }
        }
    }

    // MARK: - Center Spacer
    private var centerSpacer: some View {
        Group {
            Section { Spacer() }.listRowBackground(Color.clear)
            Section {
                HStack { Spacer() }.padding(.vertical, 37)
            }.listRowBackground(Color.clear)
            Section { Spacer() }.listRowBackground(Color.clear)
        }
    }

    // MARK: - Team 2 Header
    private var team2Header: some View {
        Section {
            HStack {
                Text("Team 2")
                Spacer()
                if isGameReady {
                    Text("\(currentPointsTeam2)")
                }
            }
        }
        .font(.title2)
        .fontWeight(.bold)
        .listRowBackground(Color.clear)
    }

    // MARK: - Team 2 Players
    private var team2Players: some View {
        Section {
            if let p3Id = player3Id, let p3 = profile(for: p3Id) {
                HStack {
                    ProfileImage(data: network.profileImages[p3Id], size: 44)
                    Text(p3.name ?? "Unknown").fontWeight(.bold)
                    Spacer()
                    if let elo = p3.elo {
                        Text("Ranking: \(elo)").foregroundStyle(.secondary).font(.system(size: 16))
                    } else {
                        Text("Download Tichu App to get ranked").foregroundStyle(.secondary).font(.system(size: 16))
                    }
                }
            } else {
                addPlayerRow(label: "Add Player 3", action: { showAddPlayersSheet3 = true })
                    .sheet(isPresented: $showAddPlayersSheet3) {
                        AddPlayersSheetView(
                            showAddPlayersSheet: $showAddPlayersSheet3,
                            addPlayerId: $player3Id,
                            alreadyAdded: [player2Id, player4Id].compactMap { $0 },
                            showGuest: .constant(true),
                            showPlayers: $showPlayers,
                            showFriends: $showFriends,
                            guestIndex: 3
                        )
                        .presentationDetents([.medium, .large])
                    }
            }

            if let p4Id = player4Id, let p4 = profile(for: p4Id) {
                HStack {
                    ProfileImage(data: network.profileImages[p4Id], size: 44)
                    Text(p4.name ?? "Unknown").fontWeight(.bold)
                    Spacer()
                    if let elo = p4.elo {
                        Text("Ranking: \(elo)").foregroundStyle(.secondary).font(.system(size: 16))
                    } else {
                        Text("Download Tichu App to get ranked").foregroundStyle(.secondary).font(.system(size: 16))
                    }
                }
            } else {
                addPlayerRow(label: "Add Player 4", action: { showAddPlayersSheet4 = true })
                    .sheet(isPresented: $showAddPlayersSheet4) {
                        AddPlayersSheetView(
                            showAddPlayersSheet: $showAddPlayersSheet4,
                            addPlayerId: $player4Id,
                            alreadyAdded: [player2Id, player3Id].compactMap { $0 },
                            showGuest: .constant(true),
                            showPlayers: $showPlayers,
                            showFriends: $showFriends,
                            guestIndex: 4
                        )
                        .presentationDetents([.medium, .large])
                    }
            }
        }
    }

    // MARK: - Add Player Row
    private func addPlayerRow(label: String, action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            Image(systemName: "plus.circle.fill")
            Button(label, action: action)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.vertical, 10.6)
            Spacer()
        }
    }

    // MARK: - VS Background
    private var vsBackground: some View {
        VStack {
            Text("VS")
                .font(.system(size: 120, weight: .bold))
            HStack {
                Text(isRated ? "Rated" : "Unrated")
                    .fontWeight(.bold)
                    .font(.title2)
                    .offset(y: -15)
                Text(isGameReady ? " \(currentGame?.target ?? target)" : " \(target)")
                    .fontWeight(.bold)
                    .font(.title2)
                    .offset(y: -15)
            }
        }
        .foregroundStyle(Color.secondary)
        .allowsHitTesting(false)
    }

    // MARK: - Game Ready Bottom Bar
    private var gameReadyBottomBar: some View {
        GlassEffectContainer {
            HStack {
                Button {
                    showEditRoundsSheet = true
                } label: {
                    Image(systemName: "list.bullet.badge.ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(width: 29, height: 29)
                        .clipShape(Circle())
                }
                .padding(10)
                .glassEffect(.regular.interactive())
                .padding(.leading, 20)
                .padding(.bottom, 10)
                .sheet(isPresented: $showEditRoundsSheet) {
                    if let game = currentGame {
                        EditRoundsSheetView(
                            showEditRoundsSheet: $showEditRoundsSheet,
                            currentGameId: game.id,
                            profiles: network.profiles,
                            network: network
                        )
                        .presentationDetents([.medium, .large])
                    }
                }

                Spacer()

                Button {
                    showAddRoundSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                    Text("Add Round").foregroundColor(.primary)
                }
                .padding(13)
                .glassEffect(.regular.interactive())
                .padding(.trailing, 20)
                .padding(.bottom, 10)
                .sheet(isPresented: $showAddRoundSheet) {
                    if let game = currentGame {
                        AddRoundSheetView(
                            showAddRoundsSheet: $showAddRoundSheet,
                            currentGameId: game.id,
                            profiles: network.profiles,
                            network: network,
                            editMode: false,
                            roundIndex: nil,
                            editingRound: nil
                        )
                    }
                }
            }
        }
    }

    // MARK: - Game Settings Bottom Bar
    private var gameSettingsBottomBar: some View {
        HStack {
            Spacer()
            Menu {
                Picker("Game Target", selection: $target) {
                    Text("250").tag(250)
                    Text("500").tag(500)
                    Text("1000").tag(1000)
                    Text("2000").tag(2000)
                    Text("10000").tag(10000)
                }
                Toggle(isOn: $allowPingus) {
                    Text("Allow Pingus")
                }
            } label: {
                Image(systemName: "gear").font(.system(size: 24))
            }
            .foregroundStyle(.primary)
            .padding(10)
            .glassEffect(.regular.interactive(), in: Circle())
            .padding(.trailing, 20)
            .padding(.bottom, 10)
        }
    }
}

