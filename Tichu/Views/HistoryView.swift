//
//  HistoryView.swift
//  Tichu
//
//  Created by Leon on 08.05.2026
//

import SwiftUI
import Charts
import TipKit

struct HistoryView: View {
    @State private var renderedImage: Image?
    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    @AppStorage("selectedTab") private var selectedTab = 1
    @AppStorage("isLoading") private var isLoading = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showDebugSheetView: Bool = false
    @State private var showLoader: Bool = false
    @State private var sheetSelectedTab: Int = 1

    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared

    // MARK: - State
    @State private var sheetGame: Game? = nil       // ✅ replaces showGameSummarySheetView + currentGameId
    @State private var selectedGameId: Int? = nil

    // MARK: - Computed

    private var gameHistory: [Game] {
        network.games.sorted { $0.date > $1.date }.filter { $0.winner != nil }
    }

    private func playerName(_ id: Int?) -> String {
        guard let id else { return "Unknown" }
        return network.profiles.first { $0.id == id }?.name ?? "Unknown"
    }

    // MARK: - Body
    var body: some View {
        if gameHistory.count > 0 {
            historyView
        } else if isLoading{
            ProgressView().scaleEffect(2)
        }else {
            emptyStateView
        }
    }

    // MARK: - History View
    private var historyView: some View {
        NavigationStack {
            GlassEffectContainer {
                GeometryReader { outerGeo in
                    let rowHeight: CGFloat = 100
                    let centerY = (outerGeo.size.height / 2 - 5)

                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0) {
                            Color.clear.frame(height: centerY - rowHeight / 2 - 10)

                            ForEach(gameHistory, id: \.id) { game in
                                gameRow(game: game, centerY: centerY, rowHeight: rowHeight)
                                    .padding(.horizontal, 10)
                                    .frame(height: rowHeight)
                                    .popoverTip(HistoryTapTip(), arrowEdge: .bottom)
                                    .contextMenu{
                                        Button{
                                            sheetGame = game
                                        }label:{
                                            Image(systemName:"arrow.up.right.square")
                                            Text("Open Game")
                                        }
                                        if let renderedImage {
                                            ShareLink(
                                                item: renderedImage,
                                                message: Text("Check my Tichu Game out."),
                                                preview: SharePreview("Tichu game", image: renderedImage)
                                            )
                                            .foregroundColor(.primary)
                                        }else{
                                            Button{}label:{
                                                HStack{
                                                    Image(systemName:"square.and.arrow.up")
                                                    Text("Share...")
                                                    ProgressView()
                                                }
                                            }.disabled(true)
                                        }
                                    }preview:{
                                        GameSummaryListView(
                                            showGameSummarySheetView: .constant(true),
                                            currentGameId: game.id,
                                            profiles: network.profiles,
                                            network: network,
                                            allowEditing: false
                                        ).onAppear {
                                            let renderer = ImageRenderer(content: GameSummaryShareView(
                                                currentGameId: game.id,
                                                rounds: network.roundsByGame[game.id ?? 0] ?? [],
                                                profiles: network.profiles,
                                                accentCo: .accent
                                            )
                                            .environment(\.colorScheme, colorScheme)
                                            .background(colorScheme == .dark ? Color.black : Color.white))
                                            renderer.scale = 3
                                            if let image = renderer.cgImage {
                                                renderedImage = Image(decorative: image, scale: 1)
                                            }
                                        }
                                    }
                            }
                            .task {
                                do {
                                    try Tips.configure()
                                } catch {
                                    print("Error initializing TipKit \(error.localizedDescription)")
                                }
                            }

                            Color.clear.frame(height: centerY - rowHeight / 2 + 20)
                        }
                        .scrollTargetLayout()
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .scrollTargetBehavior(.viewAligned)
                }
            }
            .sheet(isPresented: $showDebugSheetView) {
                DebugSheetView(
                    currentGame: .constant(network.games[0]),
                    showDebugSheetView: $showDebugSheetView
                )
            }
            .refreshable {
                Task {
                    await network.fetch()
                }
            }
            .sheet(item: $sheetGame) { game in
                GameSummarySheetView(
                    showGameOverViewSheetView: Binding(
                        get: { sheetGame != nil },
                        set: { if !$0 { sheetGame = nil } }
                    ),
                    currentGameId: game.id,
                    revanche: .constant(false),
                    profiles: network.profiles,
                    network: network,
                    selectedTab: $sheetSelectedTab,
                    showRevancheButton: false,
                    HistoryMode: true
                )
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("History")
            .toolbar {
                ToolbarItem {
                    Button { showDebugSheetView = true } label: {
                        Image(systemName: "ant")
                            .foregroundStyle(socket.connected ? Color.green : Color.red)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationProfileImage()
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
        .safeAreaInset(edge: .top) {
            if let selectedId = selectedGameId {
                GameSummaryChartView(
                    currentGameId: selectedId
                )
                .frame(height: 200)
                .padding()
                .glassEffect(
                    .regular.tint(
                        colorScheme == .dark
                        ? Color(uiColor: .tertiarySystemFill)
                        : .white
                    ).interactive(),
                    in: .rect(cornerRadius: 20)
                )
                .padding(.top, 50)
                .padding(.horizontal, 10)
                .padding(.top, 5)
            }
        }
        .onAppear {
            Task {
                showLoader = true
                await withTaskGroup(of: Void.self) { group in
                    for game in gameHistory {
                        group.addTask {
                            await network.fetchGameRounds(gameId: game.id)
                        }
                    }
                }
                if selectedGameId == nil {
                    selectedGameId = gameHistory.first?.id
                }
                showLoader = false
            }
        }
    }

    // MARK: - Game Row
    private func gameRow(game: Game, centerY: CGFloat, rowHeight: CGFloat) -> some View {
        GeometryReader { geo in
            let midY = geo.frame(in: .scrollView).midY
            let distance = abs(centerY - midY)
            let isCentered = distance < (rowHeight / 10)
            let isSelected = selectedGameId == game.id
            let opacity = max(0.35, 1 - (distance / 600))

            let scoreText = "\(game.currentPointsTeam1) : \(game.currentPointsTeam2)"
            let matchupText = "\(playerName(game.team1Player1Id)) & \(playerName(game.team1Player2Id))"
            let opponentText = "\(playerName(game.team2Player1Id)) & \(playerName(game.team2Player2Id))"

            Button {
                sheetGame = game
            } label: {
                HStack {
                    Text(scoreText)
                        .fontWeight(.bold)
                        .font(.title2)
                        .padding(.horizontal, 10)

                    VStack(alignment: .leading) {
                        HStack {
                            Text(matchupText).foregroundStyle(Color.primary)
                            Text("vs").fontWeight(.bold)
                            Text(opponentText)
                        }

                        Text(game.date, style: .date)
                            .fontWeight(.bold)
                    }

                    Spacer()
                }
                .padding(10)
                .padding(.vertical, 13)
                .background(
                    colorScheme == .dark
                    ? Color(uiColor: .tertiarySystemFill)
                    : .white,
                    in: .rect(cornerRadius: 24)
                )
                .foregroundColor(.primary)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected || isCentered
                            ? Color.accentColor
                            : Color.clear,
                            lineWidth: 2
                        )
                }
                .opacity(opacity)
            }
            .onChange(of: isCentered) { _, newValue in
                if newValue, selectedGameId != game.id {
                    selectedGameId = game.id
                }
            }
            .sensoryFeedback(.selection, trigger: isSelected)
            .onAppear {
                if selectedGameId == nil && isCentered {
                    selectedGameId = game.id
                }
            }
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        NavigationStack {
            VStack {
                Text("Your History of Tichu Games will appear here once you've played a game.")
                    .padding()
                    .sheet(isPresented: $showDebugSheetView) {
                        DebugSheetView(
                            currentGame: .constant(
                                network.games.first ??
                                Game(
                                    id: 0,
                                    date: Date(),
                                    target: 1000,
                                    allowPingus: true,
                                    currentPointsTeam1: 0,
                                    currentPointsTeam2: 0
                                )
                            ),
                            showDebugSheetView: $showDebugSheetView
                        )
                    }

                Button {
                    selectedTab = 0
                } label: {
                    Text("Play Tichu")
                }
                .padding(13)
                .glassEffect(.regular.interactive())
                .foregroundStyle(.primary)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("History")
            .toolbar {
                ToolbarItem {
                    Button { showDebugSheetView = true } label: {
                        Image(systemName: "ant")
                            .foregroundStyle(socket.connected ? Color.green : Color.red)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationProfileImage()
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }
}

#Preview {
    HistoryView()
}
