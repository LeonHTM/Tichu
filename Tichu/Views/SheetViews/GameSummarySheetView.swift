//
//  GameSummarySheetView.swift
//  Tichu
//
//  Created by Leon on 02.05.2026.
//

import SwiftUI
import UIKit

struct GameSummarySheetView: View {

    @Binding var showGameOverViewSheetView: Bool
    @State private var selectedTab: Int = 0
    @Binding var currentGame: tichuGame

    @State private var showEditRoundsSheet: Bool = false
    @State private var showDeleteGameAlert: Bool = false
    @State private var shareImageToPresent: UIImage?

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) private var displayScale

    // MARK: - Winner

    func gameWinner() -> String {

        if currentGame.currentPointsTeam1 >= currentGame.target ||
            currentGame.currentPointsTeam2 >= currentGame.target {

            if currentGame.currentPointsTeam1 > currentGame.currentPointsTeam2 {
                return "Team 1"
            } else if currentGame.currentPointsTeam2 > currentGame.currentPointsTeam1 {
                return "Team 2"
            }
        }

        return "Unknown"
    }

    // MARK: - Share

    func renderShareImage() -> UIImage? {

        let shareView = GameSummaryShareView(
            currentGame: currentGame,
            accentCo: .accent
        )
        .tint(Color.accentColor)
        .environment(\.colorScheme, colorScheme)

        let renderer = ImageRenderer(
            content: shareView
        )
        renderer.colorMode = .nonLinear

        renderer.proposedSize = ProposedViewSize(
            width: 500,
            height: 750
        )

        renderer.scale = displayScale

        return renderer.uiImage
    }

    func shareImage() {

        guard let image = renderShareImage() else { return }

        // Dismiss any active keyboard to avoid snapshotting issues
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        // Defer to next run loop so SwiftUI can coordinate sheet presentations
        DispatchQueue.main.async {
            self.shareImageToPresent = image
        }
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ZStack(alignment: .top) {

                Group {

                    switch selectedTab {

                    case 0:

                        VStack {
                            
                            GameSummaryChartView(
                                currentGame: $currentGame
                            )
                            .frame(width: 350)

                            Spacer()
                        }

                    case 1:

                        GameSummaryListView(
                            showGameSummarySheetView: $showGameOverViewSheetView,
                            currentGame: $currentGame
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

            .alert(
                "Delete this Game?",
                isPresented: $showDeleteGameAlert
            ) {

                Button("Cancel", role: .cancel) {
                    showDeleteGameAlert = false
                }

                Button("Delete", role: .destructive) {

                    showEditRoundsSheet = false

                    DispatchQueue.main.async {
                        currentGame = tichuGame()
                    }
                }

            } message: {

                Text("This Game will be deleted")
            }

            .sheet(item: $shareImageToPresent) { image in
                ActivityViewController(activityItems: [image])
            }

            .safeAreaInset(edge: .bottom) {
                GlassEffectContainer{
                HStack {
                    
                    
                    
                    Button {
                        DispatchQueue.main.async{
                            shareImage()
                        }
                        
                    } label: {
                        
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                            .frame(width: 29, height: 29)
                            .clipShape(Circle())
                    }
                    .padding(10)
                    .foregroundColor(.primary)
                    .glassEffect(.regular.interactive())
                    
                    
                    Spacer()
                    
                    HStack{
                        
                        Text("\(currentGame.currentPointsTeam1)")
                            .fontWeight(.bold)
                            .font(.title3)
                        
                        
                        Text("vs").fontWeight(.bold)
                            .font(.title3)
                        
                        
                        Text("\(currentGame.currentPointsTeam2)")
                            .fontWeight(.bold)
                            .font(.title3)
                        
                    }.padding(13).glassEffect(.regular.tint(.accent).interactive())
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
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
            }
            }

            .navigationTitle("\(currentGame.winner?.name ?? "Unknown") won!")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button(role: .cancel) {

                        showGameOverViewSheetView = false

                        DispatchQueue.main.async {
                            currentGame = tichuGame()
                        }

                    } label: {

                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {

                    Button(role: .confirm) {

                        showGameOverViewSheetView = false

                        let p1 = currentGame.player1!
                        let p2 = currentGame.player2!
                        let p3 = currentGame.player3!
                        let p4 = currentGame.player4!

                        currentGame = tichuGame(
                            player1: p1,
                            player2: p2,
                            player3: p3,
                            player4: p4
                        )

                    } label: {

                        Text("Revanche")
                    }
                }
            }
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension UIImage: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}





#Preview {

    GameSummarySheetView(
        showGameOverViewSheetView: .constant(true),
        currentGame: .constant(exampleGame)
    )
}

