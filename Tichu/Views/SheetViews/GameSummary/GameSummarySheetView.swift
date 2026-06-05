//
//  GameSummarySheetView.swift
//  Tichu
//
//  Created by Leon on 02.05.2026.
//

import SwiftUI
import UIKit

struct GameSummarySheetView: View {
    
    @AppStorage("isLoadingShare") private var isLoadingShare: Bool = false

    // MARK: - Bindings
    @Binding var showGameOverViewSheetView: Bool
    var currentGameId: Int?
    @Binding var revanche: Bool

    // MARK: - Dependencies
    let profiles: [Profile]
    @ObservedObject var network: NetworkService

    // MARK: - State
    @Binding var selectedTab: Int
    @State private var showDeleteGameAlert: Bool = false
    @State private var shareImageToPresent: UIImage?
    @State private var renderedImage: Image?

    // MARK: - Props
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) private var displayScale
    var showRevancheButton: Bool
    var HistoryMode: Bool

    private var currentGame: Game? {
        network.games.first(where: { $0.id == currentGameId })
    }

    private var winnerName: String {
        guard let winnerId = currentGame?.winner else { return "Unknown" }
        if winnerId == 1 { return "Team 1" }
        if winnerId == 2 { return "Team 2" }
        return "Unknown"
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                gameContent
                if isLoadingShare {
                    ProgressView()
                }
            }
            .sheet(isPresented: Binding(
                get: { shareImageToPresent != nil },
                set: { if !$0 { shareImageToPresent = nil } }
            )) {
                if let image = shareImageToPresent {
                    ActivityViewController(
                        title: "Tichu Game from \(currentGame?.date.formatted(date: .numeric, time: .omitted) ?? "Unknown")",
                        message: "Made with Tichu-App.",
                        image: image
                    )
                }
            }
            .toolbar {
                bottomToolbar
                toolbarContent
            }
            .navigationTitle("\(winnerName) won!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Game Content
    private var gameContent: some View {
        Group {
            switch selectedTab {
            case 0:
                VStack {
                    GameSummaryChartView(currentGameId: currentGameId)
                        .frame(width: 350)
                    Spacer()
                }
            case 1:
                GameSummaryListView(
                    showGameSummarySheetView: $showGameOverViewSheetView,
                    currentGameId: currentGameId,
                    profiles: profiles,
                    network: network,
                    allowEditing: !HistoryMode
                )
                .padding(.bottom, -50)
            default:
                EmptyView()
            }
        }
        .onAppear {
            let renderer = ImageRenderer(content: GameSummaryShareView(
                currentGameId: currentGameId,
                rounds: network.roundsByGame[currentGameId ?? 0] ?? [],
                profiles: profiles,
                accentCo: .accent
            )
            .environment(\.colorScheme, colorScheme)
            .background(colorScheme == .dark ? Color.black : Color.white))
            renderer.scale = 3
            if let image = renderer.cgImage {
                renderedImage = Image(decorative: image, scale: 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .top) {
            Picker("View", selection: $selectedTab) {
                Text("Graph").tag(0)
                Text("List").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    // MARK: - Bottom Toolbar
    @ToolbarContentBuilder
    private var bottomToolbar: some ToolbarContent {
        GameSummaryBottomToolbar(
            renderedImage: renderedImage,
            currentGame: currentGame,
            HistoryMode: HistoryMode,
            showDeleteGameAlert: $showDeleteGameAlert,
            showGameOverViewSheetView: $showGameOverViewSheetView,
            network: network,
            currentGameId: currentGameId
        )
    }

    // MARK: - Top Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                showGameOverViewSheetView = false
            } label: {
                Image(systemName: "xmark")
            }
        }
        if showRevancheButton {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    revanche = true
                    showGameOverViewSheetView = false
                } label: {
                    Text("Revanche")
                }
            }
        }
    }
}

// MARK: - GameSummaryBottomToolbar

struct GameSummaryBottomToolbar: ToolbarContent {
    //@Namespace private var ShareSheetSpace
    let renderedImage: Image?
    let currentGame: Game?
    let HistoryMode: Bool
    @Binding var showDeleteGameAlert: Bool
    @Binding var showGameOverViewSheetView: Bool
    @ObservedObject var network: NetworkService
    let currentGameId: Int?

    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            if let renderedImage {
                ShareLink(
                    item: renderedImage,
                    message: Text("Check my Tichu Game out."),
                    preview: SharePreview("Tichu game", image: renderedImage)
                )
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .foregroundColor(.primary)
            }
        }

        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }

        ToolbarItem(placement: .bottomBar) {
            Button {} label: {
                HStack {
                    Text("\(currentGame?.currentPointsTeam1 ?? 0)")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                    Text("vs").fontWeight(.bold).font(.title3)
                    Text("\(currentGame?.currentPointsTeam2 ?? 0)")
                        .fontWeight(.bold)
                }
            }
        }

        if !HistoryMode {
            ToolbarSpacer(placement:.bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showDeleteGameAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .foregroundColor(.primary)
                .alert("Delete this Game?", isPresented: $showDeleteGameAlert) {
                    fuckyouView(showDeleteGameAlert: $showDeleteGameAlert, currentGameId: currentGameId ?? 0, showGameOverViewSheetView: $showGameOverViewSheetView)//.navigationTransition(.zoom(sourceID: "69420", in: ShareSheetSpace))
                } message: {
                    Text("This Game will be deleted")
                }
            }//.matchedTransitionSource(id: "69420", in: ShareSheetSpace)
        }else{
            ToolbarSpacer(placement:.bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button{
                    
                        Task{
                            await network.updateGameFavorite(gameId: currentGameId ?? 0, favorite: !currentGame!.favorite )
                        }
                    
                }label:{
                    Image(systemName: currentGame!.favorite ? "star.slash.fill" :"star.fill")
                }.sensoryFeedback(.success,trigger:currentGame!.favorite)
                
            }
        }
    }
}

struct fuckyouView: View{
    @Binding var showDeleteGameAlert: Bool
    var currentGameId: Int
    @Binding var showGameOverViewSheetView: Bool
    var body: some View{
        Button("Cancel", role: .cancel) { showDeleteGameAlert = false }
        Button("Delete", role: .destructive) {
            Task {
                await NetworkService.shared.deleteGame(gameId: currentGameId ?? 0)
                showGameOverViewSheetView = false
            }
        }
    }
}
