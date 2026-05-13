//
//  GameSummarySheetView.swift
//  Tichu
//
//  Created by Leon on 02.05.2026.
//

import SwiftUI
import UIKit

struct GameSummarySheetView: View {

    // MARK: - Bindings
    @Binding var showGameOverViewSheetView: Bool
    @Binding var currentGame: tichuGame

    // MARK: - State
    @State private var selectedTab: Int = 0
    @State private var showDeleteGameAlert: Bool = false
    @State private var shareImageToPresent: UIImage?

    // MARK: - Props
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) private var displayScale
    var showRevancheButton: Bool
    var HistoryMode: Bool

    // MARK: - Share
    func renderShareImage() -> UIImage? {
        let shareView = GameSummaryShareView(currentGame: currentGame, accentCo: .accent)
            .tint(Color.accentColor)
            .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: shareView)
        renderer.colorMode = .nonLinear
        renderer.proposedSize = ProposedViewSize(width: 500, height: 750)
        renderer.scale = displayScale
        return renderer.uiImage
    }

    func shareImage() {
        guard let image = renderShareImage() else { return }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        DispatchQueue.main.async { self.shareImageToPresent = image }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                if HistoryMode {
                    historyContent
                } else {
                    gameContent
                }
            }
            .alert("Delete this Game?", isPresented: $showDeleteGameAlert) {
                Button("Cancel", role: .cancel) { showDeleteGameAlert = false }
                Button("Delete", role: .destructive) {
                    DispatchQueue.main.async { currentGame = tichuGame() }
                }
            } message: {
                Text("This Game will be deleted")
            }
            .sheet(item: $shareImageToPresent) { image in
                ActivityViewController(activityItems: [image])
            }
            .safeAreaInset(edge: .bottom) { bottomBar }
            .navigationTitle("\(currentGame.winner?.name ?? "Unknown") won!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    // MARK: - History Content
    private var historyContent: some View {
        GameSummaryListView(
            showGameSummarySheetView: $showGameOverViewSheetView,
            currentGame: $currentGame,
            allowEditing: false
        )
        .padding(.bottom, -50)
    }

    // MARK: - Game Content
    private var gameContent: some View {
        Group {
            switch selectedTab {
            case 0:
                VStack {
                    GameSummaryChartView(currentGame: $currentGame).frame(width: 350)
                    Spacer()
                }
            case 1:
                GameSummaryListView(
                    showGameSummarySheetView: $showGameOverViewSheetView,
                    currentGame: $currentGame,
                    allowEditing: !HistoryMode
                )
                .padding(.bottom, -50)
            default:
                EmptyView()
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

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        GlassEffectContainer {
            HStack {
                Button {
                    DispatchQueue.main.async { shareImage() }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 22))
                       
                }
                .padding(10)
                .foregroundColor(.primary)
                .glassEffect(.regular.interactive(),in:Circle())

                Spacer()

                HStack {
                    Text("\(currentGame.currentPointsTeam1)").fontWeight(.bold).font(.title3).foregroundStyle(Color.accentColor)
                    Text("vs").fontWeight(.bold).font(.title3)
                    Text("\(currentGame.currentPointsTeam2)").fontWeight(.bold).font(.title3)
                }
                .padding(13)
                .glassEffect(.regular.interactive())

                if !HistoryMode {
                    Spacer()
                    Button {
                        showDeleteGameAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 22))
                            .frame(width: 29, height: 29)
                            .clipShape(Circle())
                    }
                    .foregroundColor(.primary)
                    .padding(10)
                    .glassEffect(.regular.interactive())
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                showGameOverViewSheetView = false
                DispatchQueue.main.async { currentGame = tichuGame() }
            } label: {
                Image(systemName: "xmark")
            }
        }
        if showRevancheButton {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    showGameOverViewSheetView = false
                    let p1 = currentGame.player1!
                    let p2 = currentGame.player2!
                    let p3 = currentGame.player3!
                    let p4 = currentGame.player4!
                    currentGame = tichuGame(player1: p1, player2: p2, player3: p3, player4: p4)
                } label: {
                    Text("Revanche")
                }
            }
        }
    }
}

#Preview {
    GameSummarySheetView(
        showGameOverViewSheetView: .constant(true),
        currentGame: .constant(exampleGame),
        showRevancheButton: true,
        HistoryMode: true
    )
}
