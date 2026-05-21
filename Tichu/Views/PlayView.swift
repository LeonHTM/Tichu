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

    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared

    // MARK: - ViewModel
    @StateObject private var viewModel: PlayViewModel

    init() {
        // Bootstrap the VM with current AppStorage values at init time
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let userName = UserDefaults.standard.string(forKey: "userName") ?? "Storage - Unknown"
        let userElo = UserDefaults.standard.integer(forKey: "userElo")
        let userImageData = UserDefaults.standard.data(forKey: "userImageData")
        _viewModel = StateObject(wrappedValue: PlayViewModel(
            userId: userId,
            userName: userName,
            userElo: userElo,
            userImageData: userImageData
        ))
    }

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

    @State private var team1 = Team()
    @State private var team2 = Team()
    @State private var currentRound = Round()
    @State private var revanche: Bool = false

    @FocusState private var targetFieldFocused: Bool

    // MARK: - Convenience
    private var currentGame: tichuGame {
        get { viewModel.currentGame }
    }

    // MARK: - Computed
    private var isGameReady: Bool {
        viewModel.currentGame.player2 != nil && viewModel.currentGame.player3 != nil && viewModel.currentGame.player4 != nil
    }

    private var gameDone: Bool {
        viewModel.currentGame.winner != nil
    }

    private var isRated: Bool {
        let players = [
            viewModel.currentGame.player1,
            viewModel.currentGame.player2,
            viewModel.currentGame.player3,
            viewModel.currentGame.player4
        ].compactMap { $0 }
        return !players.contains { $0.elo == nil }
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
                }.refreshable {
                    await network.fetch(isLoading: .constant(false))
                    viewModel.loadUser()
                }.onAppear {
                    print("appearing")
                    viewModel.loadUser()
                }.onChange(of: socket.connected) {
                    if !socket.connected {
                        showFriends = false
                        showPlayers = false
                    } else {
                        showFriends = true
                        showPlayers = true
                    }
                }
                .onChange(of: isGameReady) {
                    if let _ = viewModel.currentGame.player2?.name {
                        team1 = Team(list: [viewModel.currentGame.player1!, viewModel.currentGame.player2!], name: "Team 1")
                    }
                    if let _ = viewModel.currentGame.player3?.name, let _ = viewModel.currentGame.player4?.name {
                        team2 = Team(list: [viewModel.currentGame.player3!, viewModel.currentGame.player4!], name: "Team 2")
                    }
                    if isGameReady == false { viewModel.loadUser() }
                    currentRound.team1 = team1
                    currentRound.team2 = team2
                    viewModel.currentGame.team1 = team1
                    viewModel.currentGame.team2 = team2
                }
                .onChange(of: gameDone) {
                    showGameOverSheet = gameDone
                }
                .sheet(isPresented: $showGameOverSheet, onDismiss: {
                    if revanche == true {
                        let p1 = viewModel.currentGame.player1!
                        let p2 = viewModel.currentGame.player2!
                        let p3 = viewModel.currentGame.player3!
                        let p4 = viewModel.currentGame.player4!
                        withAnimation(.easeInOut) {
                            viewModel.currentGame = tichuGame(player1: p1, player2: p2, player3: p3, player4: p4)
                        }
                    } else {
                        withAnimation(.easeInOut) {
                            viewModel.currentGame = tichuGame()
                            viewModel.loadUser()
                        }
                    }
                }) {
                    GameSummarySheetView(
                        showGameOverViewSheetView: $showGameOverSheet,
                        currentGame: $viewModel.currentGame,
                        revanche: $revanche,
                        showRevancheButton: true,
                        HistoryMode: false
                    )
                    .presentationDetents([.medium])
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
                currentGame: $viewModel.currentGame,
                showDebugSheetView: $showDebugSheetView,
                exampleGameHistory: .constant([])
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
                    Text("\(viewModel.currentGame.currentPointsTeam1)")
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
                ProfileImage(data: viewModel.currentGame.player1?.imageData, size: 44)
                VStack(alignment: .leading) {
                    Text(viewModel.currentGame.player1?.name ?? "Unknown")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                }
                Spacer()
                Text("Ranking: \(viewModel.currentGame.player1?.elo ?? -69420)")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
            }

            if let name2 = viewModel.currentGame.player2?.name {
                HStack {
                    ProfileImage(data: viewModel.currentGame.player2!.imageData, size: 44)
                    Text(name2).fontWeight(.bold).foregroundStyle(Color.accentColor)
                    Spacer()
                    if let elo = viewModel.currentGame.player2?.elo {
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
                            addPlayer: $viewModel.currentGame.player2,
                            alreadyAdded: [viewModel.currentGame.player3, viewModel.currentGame.player4].compactMap { $0 },
                            showGuest: .constant(true), showPlayers: $showPlayers, showFriends: $showFriends, guestIndex: 2
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
                    Text("\(viewModel.currentGame.currentPointsTeam2)")
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
            if let name3 = viewModel.currentGame.player3?.name {
                HStack {
                    ProfileImage(data: viewModel.currentGame.player3!.imageData, size: 44)
                    Text(name3).fontWeight(.bold)
                    Spacer()
                    if let elo = viewModel.currentGame.player3?.elo {
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
                            addPlayer: $viewModel.currentGame.player3,
                            alreadyAdded: [viewModel.currentGame.player2, viewModel.currentGame.player4].compactMap { $0 },
                            showGuest: .constant(true), showPlayers: $showPlayers, showFriends: $showFriends, guestIndex: 3
                        )
                        .presentationDetents([.medium, .large])
                    }
            }

            if let name4 = viewModel.currentGame.player4?.name {
                HStack {
                    ProfileImage(data: viewModel.currentGame.player4!.imageData, size: 44)
                    Text(name4).fontWeight(.bold)
                    Spacer()
                    if let elo = viewModel.currentGame.player4?.elo {
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
                            addPlayer: $viewModel.currentGame.player4,
                            alreadyAdded: [viewModel.currentGame.player2, viewModel.currentGame.player3].compactMap { $0 },
                            showGuest: .constant(true), showPlayers: $showPlayers, showFriends: $showFriends, guestIndex: 4
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
                Text(isGameReady ? " \(viewModel.currentGame.target)" : " ")
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
                if viewModel.currentGame.Rounds.count > 0 {
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
                        EditRoundsSheetView(
                            showEditRoundsSheet: $showEditRoundsSheet,
                            currentGame: $viewModel.currentGame
                        )
                        .presentationDetents([.medium, .large])
                    }
                } else {
                    Button {
                        withAnimation(.easeInOut) { viewModel.currentGame = tichuGame() }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Game")
                        }
                        .foregroundColor(.primary)
                        .padding(13)
                        .glassEffect(.regular.interactive())
                    }
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
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
                .sheet(isPresented: $showAddRoundSheet, onDismiss: {
                    currentRound = Round()
                }) {
                    AddRoundSheetView(
                        showAddRoundsSheet: $showAddRoundSheet,
                        currentGame: $viewModel.currentGame,
                        currentRound: $currentRound,
                        editMode: false,
                        roundIndex: nil
                    )
                }
            }
        }
    }

    // MARK: - Game Settings Bottom Bar
    private var gameSettingsBottomBar: some View {
        HStack {
            Spacer()
            Menu {
                Picker("Game Target", selection: $viewModel.currentGame.target) {
                    Text("250").tag(250)
                    Text("500").tag(500)
                    Text("1000").tag(1000)
                    Text("2000").tag(2000)
                    Text("10000").tag(10000)
                }
                Toggle(isOn: $viewModel.currentGame.allowPingus) {
                    Text("Allow Pingus")
                }
            } label: {
                Image(systemName: "gear").font(.system(size: 24))
            }
            .foregroundStyle(.primary)
            .padding(10)
            .glassEffect(.regular.interactive(), in: Circle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    PlayView()
}
