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

    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    @AppStorage("selectedTab") private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var showDebugSheetView: Bool = false

    @StateObject private var socket = SocketService.shared
    @ObservedObject private var network = NetworkService.shared

    // MARK: - State
    @State private var showGameSummarySheetView: Bool = false
    @State private var currentGameE: Game = Game(id: 0, date: Date(), target: 1000, allowPingus: true, currentPointsTeam1: 0, currentPointsTeam2: 0)
    @State private var selectedGame: Game? = nil

    // MARK: - Computed

    private var gameHistory: [Game] {
        network.games.sorted { $0.date > $1.date }
    }

    private func rounds(for game: Game) -> [Round] {
        network.roundsByGame[game.id] ?? []
    }

    private func playerName(_ id: Int?) -> String {
        guard let id else { return "Unknown" }
        return network.profiles.first { $0.id == id }?.name ?? "Unknown"
    }

    // MARK: - Body
    var body: some View {
        if gameHistory.count > 0 {
            historyView
        } else {
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
                                gameRow(currentGame: game, centerY: centerY, rowHeight: rowHeight)
                                    .padding(.horizontal, 10)
                                    .frame(height: rowHeight)
                                    .scrollTargetLayout()
                                    .popoverTip(HistoryTapTip(), arrowEdge: .bottom)
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
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .scrollTargetBehavior(.viewAligned)
                }
            }.sheet(isPresented: $showDebugSheetView) {
                DebugSheetView(currentGame: .constant(network.games[0]),showDebugSheetView: $showDebugSheetView)
                
            }
            .refreshable {
                Task{
                    await network.fetch(isLoading:.constant(true))
                }
                
            }
            .sheet(isPresented: $showGameSummarySheetView) {
                GameSummarySheetView(
                    showGameOverViewSheetView: $showGameSummarySheetView,
                    currentGame: $currentGameE,
                    revanche: .constant(false),
                    profiles: network.profiles,
                    network: network,
                    showRevancheButton: false,
                    HistoryMode: true
                )
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("History")
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
        }
        .safeAreaInset(edge: .top) {
            if let selected = selectedGame {
                GameSummaryChartView(
                    currentGame: .constant(selected),
                    rounds: rounds(for: selected)
                )
                .frame(height: 200)
                .padding()
                .glassEffect(.regular.tint(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white).interactive(), in: .rect(cornerRadius: 20))
                .padding(.top, 50)
                .padding(.horizontal, 10)
                .padding(.top, 5)
            }
        }
        .onAppear {
            if selectedGame == nil {
                selectedGame = gameHistory.first
            }
            Task {
                for game in gameHistory {
                    await network.fetchGameRounds(gameId: game.id)
                }
            }
        }
    }

    // MARK: - Game Row
    private func gameRow(currentGame: Game, centerY: CGFloat, rowHeight: CGFloat) -> some View {
        GeometryReader { geo in
            let midY = geo.frame(in: .scrollView).midY
            let distance = abs(centerY - midY)
            let isCentered = distance < (rowHeight / 10)
            let isSelected = selectedGame?.id == currentGame.id
            let opacity = max(0.35, 1 - (distance / 600))

            let scoreText = "\(currentGame.currentPointsTeam1) : \(currentGame.currentPointsTeam2)"
            let matchupText = "\(playerName(currentGame.team1Player1Id)) & \(playerName(currentGame.team1Player2Id))"
            let opponentText = "\(playerName(currentGame.team2Player1Id)) & \(playerName(currentGame.team2Player2Id))"

            Button {
                currentGameE = currentGame
                showGameSummarySheetView = true
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
                        Text(currentGame.date, style: .date).fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding(10)
                .padding(.vertical, 13)
                .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                .foregroundColor(.primary)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected || isCentered ? Color.accentColor : Color.clear, lineWidth: 2)
                }
                .opacity(opacity)
            }
            .onChange(of: isCentered) { _, newValue in
                if newValue, selectedGame?.id != currentGame.id {
                    selectedGame = currentGame
                }
            }
            .sensoryFeedback(.selection, trigger: isSelected)
            .onAppear {
                if selectedGame == nil && isCentered {
                    selectedGame = currentGame
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
                            currentGame: $currentGameE,
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
                        Image(systemName: "ant").foregroundStyle(socket.connected ? Color.green : Color.red)
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
