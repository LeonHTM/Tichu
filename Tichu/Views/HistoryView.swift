//
//  HistoryView.swift
//  Tichu
//

import SwiftUI
import Charts

struct HistoryView: View {

    // Storage
    @AppStorage("userImageData") private var userImageData: Data?
    @AppStorage("selectedTab") private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    

    // State
    @State private var selectedImage: UIImage?
    @State private var currentGameE = tichuGame()
    @State private var gameHistory: [tichuGame] = exampleHistory
    @State private var showGameSummarySheetView: Bool = false
    @State private var selectedGame: tichuGame = tichuGame()
    @State private var showDebugSheetView: Bool = false
    

    var body: some View {
        if gameHistory.count > 0 {
            NavigationStack {
            
            GlassEffectContainer {
                
                GeometryReader { outerGeo in
                    
                    let rowHeight: CGFloat = 100
                    let centerY = (outerGeo.size.height / 2 - 5)
                    
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0) {
                            
                            // top padding for centering
                            Color.clear
                                .frame(height: centerY - rowHeight / 2-13)
                            
                            ForEach(gameHistory, id: \.id) { currentGame in
                                
                                GeometryReader { geo in
                                    
                                    let midY = geo.frame(in: .scrollView).midY
                                    let distance = abs(centerY - midY)
                                    
                                    let isCentered = distance < (rowHeight / 10)
                                    let isSelected = selectedGame.id == currentGame.id
                                    
                                    // fade
                                    let opacity = max(0.35, 1 - (distance / 600))
                                    
                                    
                                    let scoreText = "\(currentGame.currentPointsTeam1) : \(currentGame.currentPointsTeam2)"
                                    let team1Name0 = currentGame.team1?.list.indices.contains(0) == true ? currentGame.team1?.list[0].name ?? "Unknown" : "Unknown"
                                    let team1Name1 = currentGame.team1?.list.indices.contains(1) == true ? currentGame.team1?.list[1].name ?? "Unknown" : "Unknown"
                                    let team2Name0 = currentGame.team2?.list.indices.contains(0) == true ? currentGame.team2?.list[0].name ?? "Unknown" : "Unknown"
                                    let team2Name1 = currentGame.team2?.list.indices.contains(1) == true ? currentGame.team2?.list[1].name ?? "Unknown" : "Unknown"
                                    let matchupText = "\(team1Name0) & \(team1Name1)"
                                    let opponentText = "\(team2Name0) & \(team2Name1)"
                                    
                                    Button {
                                        showGameSummarySheetView = true
                                        currentGameE = currentGame
                                    } label: {
                                        
                                        HStack {
                                            
                                            Text(scoreText)
                                                .fontWeight(.bold)
                                                .font(.title2)
                                                .padding(.horizontal, 10)
                                            
                                            VStack(alignment: .leading) {
                                                
                                                HStack {
                                                    Text(matchupText)
                                                    
                                                    Text("vs")
                                                        .fontWeight(.bold)
                                                    
                                                    Text(opponentText)
                                                }
                                                
                                                Text(currentGame.date, style: .date)
                                                    .fontWeight(.bold)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(10)
                                        .padding(.vertical, 13)
                                        .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                                        .foregroundColor(.primary)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(isSelected || isCentered
                                                        ? Color.accentColor
                                                        : Color.clear,
                                                        lineWidth: 2)
                                        }
                                        .opacity(opacity)
                                    }
                                    .onChange(of: isCentered) { oldValue, newValue in
                                        if newValue, selectedGame.id != currentGame.id {
                                            selectedGame = currentGame
                                        }
                                    }
                                    .sensoryFeedback(.selection, trigger: isSelected)
                                    .onAppear {
                                        
                                        if selectedGame.id == exampleGame.id || selectedGame.id == UUID() {
                                            
                                            if isCentered {
                                                selectedGame = currentGame
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .frame(height: rowHeight)
                                .scrollTargetLayout()
                            }
                            
                            // bottom padding
                            Color.clear
                                .frame(height: centerY - rowHeight / 2+50)
                        }
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .scrollTargetBehavior(.viewAligned)
                }
            }
            
            .sheet(isPresented: $showGameSummarySheetView) {
                GameSummarySheetView(
                    showGameOverViewSheetView: $showGameSummarySheetView,
                    currentGame: $currentGameE,
                    showRevancheButton: false,
                    HistoryMode: true
                )
            }
            .onChange(of: showGameSummarySheetView) {
                currentGameE.reCount()
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("History")
            
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing) {
                    ProfileImage(data: userImageData, size: 44)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }.safeAreaInset(edge: .top) {
            
            GameSummaryChartView(currentGame: $selectedGame ).frame(height:200).padding().glassEffect( .regular.tint(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white,).interactive(), in: .rect(cornerRadius: 20) ).padding(.top,50).padding(.horizontal,10).padding(.top,5)
            
            
            
        }
        .onAppear {
            for index in gameHistory.indices {
                gameHistory[index].reCount()
            }
            selectedGame = gameHistory[0]
            selectedImage = dataToPhoto(data: userImageData)
            
        }
        }else{
            NavigationStack{
                VStack{
                    Text("Your History of Tichu Games will appear here once you've played a game.").padding()
                        .sheet(isPresented: $showDebugSheetView){
                            DebugSheetView(currentGame:$selectedGame,showDebugSheetView: $showDebugSheetView,exampleGameHistory: $gameHistory)
                        }
                    Button{
                        selectedTab = 0
                    }label:{
                        Text("Play Tichu")
                    }.padding(13).glassEffect(.regular.interactive()).foregroundStyle(.primary)
                }.toolbarTitleDisplayMode(.inlineLarge)
                    .navigationTitle("History")
                    
                    .toolbar {
                        ToolbarItem(){
                            Button{
                                showDebugSheetView = true
                            }label:{
                                Image(systemName:"ant")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            ProfileImage(data: userImageData, size: 44)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                   
            }
                
        }
    }
}

#Preview {
    HistoryView()
}
