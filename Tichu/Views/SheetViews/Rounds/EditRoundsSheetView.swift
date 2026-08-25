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
    
    @State private var showDeleteGameAlert: Bool = false
    @ObservedObject var network: NetworkService
    
    // MARK: - Bindings
    @Binding var showEditRoundsSheet: Bool
    var currentGameId: Int
    
    private var currentGame: Game? {
        network.games.first(where: { $0.id == currentGameId })
    }
    
    private var allRounds: [Round] {
        (network.roundsByGame[currentGameId] ?? [])
            .sorted { $0.roundOrder < $1.roundOrder }
    }
    
    private var currentPointsTeam1: Int { currentGame?.currentPointsTeam1 ?? -69420 }
    private var currentPointsTeam2: Int { currentGame?.currentPointsTeam2 ?? -69420 }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
                if allRounds.count > 0 {
                    GameSummaryListView(
                                                    showGameSummarySheetView: $showEditRoundsSheet,
                                                    currentGameId: currentGameId,
                                                    profiles: network.profiles,
                                                    network: network,
                                                    allowEditing: .constant(true)
                    ).toolbar { roundsListToolbar }
                } else {
                    Text(String(localized:"rounds.noPlayed"))
                        .foregroundStyle(.secondary)
                        .toolbar { roundsListToolbar }
                }
            
        }
        .safeAreaInset(edge: .top)    { scoreHeader }
        .safeAreaInset(edge: .bottom) { deleteGameButton }
        .alert(String(localized:"gameSummary.alert.delete.title"), isPresented: $showDeleteGameAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteGameAlert = false
            }
            Button(String(localized:"general.delete"), role: .destructive) {
                Task {
                    await network.deleteGame(gameId: currentGameId)
                    showEditRoundsSheet = false
                }
            }
        } message: {
            Text(String(localized:"gameSummary.alert.delete.description"))
        }
    }



    // MARK: - Score Header
    private var scoreHeader: some View {
        HStack {
            
            Text(String(format:String(localized:"general.team.result"),String(1), String(currentPointsTeam1))).foregroundStyle(Color.accentColor)
            Spacer()
            Text(String(format:String(localized:"general.team.result"),String(2), String(currentPointsTeam1)))
        }
        .fontWeight(.bold)
        .font(.title2)
        .padding(.horizontal, 30)
        .padding(.top, 70)
    }

    // MARK: - Delete Game Button
    private var deleteGameButton: some View {
        Button {
            showDeleteGameAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text(String(localized:"gameSummary.deleteGame"))
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
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", systemImage: "checkmark") {
                showEditRoundsSheet = false
            }
        }
    }
}



