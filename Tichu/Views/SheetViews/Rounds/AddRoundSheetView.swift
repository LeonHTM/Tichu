//
//  AddRoundSheetView.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI

struct AddRoundSheetView: View {
    @AppStorage("dragMode") var dragMode: Bool = false
    @State private var hasAnnouncedPlayer1: CanAnnounce = .none
    @State private var hasAnnouncedPlayer2: CanAnnounce = .none
    @State private var hasAnnouncedPlayer3: CanAnnounce = .none
    @State private var hasAnnouncedPlayer4: CanAnnounce = .none
    @State private var players: [Profile?] = []
    @State private var counter: Int = 0
    @Binding var showAddRoundsSheet: Bool
    @Binding var currentGame: tichuGame
    @Binding var currentRound: Round
    @Environment(\.colorScheme) var colorScheme
    var editMode: Bool
    let roundIndex: Int?
    @State private var hasPushedList: [Bool] = [false,false,false,false]
    @State private var rankingList:[Int] = [0,0,0,0]
    
    private var displayTeam1Points: Int {
        if hasDoubleWinTeam1 {
            return 100
        }
        if hasDoubleWinTeam2 {
            return 0
        }
        return currentRound.tichuPointsTeam1
    }

    private var displayTeam2Points: Int {
        if hasDoubleWinTeam2 {
            return 100
        }
        if hasDoubleWinTeam1 {
            return 0
        }
        return currentRound.tichuPointsTeam2
    }
    
    private func applyDoubleWin() {
        if hasDoubleWinTeam1 {
            currentRound.tichuPointsTeam1 = 100
            currentRound.tichuPointsTeam2 = 0
        } else if hasDoubleWinTeam2 {
            currentRound.tichuPointsTeam1 = 0
            currentRound.tichuPointsTeam2 = 100
        }
    }
   
    
    func move(from source: IndexSet, to destination: Int) {
        players.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Team logic
    private func isTeam1(_ player: Profile?) -> Bool {
        guard let player else { return false }
        return player.id == currentGame.player1?.id || player.id == currentGame.player2?.id
    }
    
    private func isTeam2(_ player: Profile?) -> Bool {
        guard let player else { return false }
        return player.id == currentGame.player3?.id || player.id == currentGame.player4?.id
    }
    
   
    private func isGolden(index: Int) -> Bool {
        guard index < 2 else { return false }
        guard players.count >= 2 else { return false }
        
        let first = players[0]
        let second = players[1]
        
        if let first, let second {
            let sameTeam = (isTeam1(first) && isTeam1(second)) ||
                          (isTeam2(first) && isTeam2(second))
            return sameTeam
        }
        return false
    }
    private func isGolden2(index: Int) -> Bool {
        // Determine the indices of the players who have been marked as rank 1 and 2
        guard let firstIndex = rankingList.firstIndex(of: 1),
              let secondIndex = rankingList.firstIndex(of: 2) else {
            return false
        }
        // Only highlight rows that correspond to rank 1 or rank 2
        guard index == firstIndex || index == secondIndex else { return false }
        
        let first = players[firstIndex]
        let second = players[secondIndex]
        
        if let first, let second {
            let sameTeam = (isTeam1(first) && isTeam1(second)) ||
                           (isTeam2(first) && isTeam2(second))
            return sameTeam
        }
        return false
    }
   
    
    func announcement(for player: Profile?) -> CanAnnounce {
        guard let player else { return .none }

        if currentRound.hasAnnouncedBigTichu.contains(where: { $0.id == player.id }) {
            return .bigTichu
        }

        if currentRound.hasAnnouncedTichu.contains(where: { $0.id == player.id }) {
            return .tichu
        }

        if currentRound.hasAnnouncedPingu.contains(where: { $0.id == player.id }) {
            return .pingu
        }

        return .none
    }
    
    
    func updateAnnouncement(
        player: Profile,
        state: CanAnnounce
    ) {
        currentRound.hasAnnouncedTichu.removeAll { $0.id == player.id }
        currentRound.hasAnnouncedBigTichu.removeAll { $0.id == player.id }
        currentRound.hasAnnouncedPingu.removeAll { $0.id == player.id }

        switch state {
        case .tichu:
            currentRound.hasAnnouncedTichu.append(player)

        case .bigTichu:
            currentRound.hasAnnouncedBigTichu.append(player)

        case .pingu:
            currentRound.hasAnnouncedPingu.append(player)

        case .none:
            break
        }
    }
    
    func saveRound(){
        if dragMode == true{
            currentRound.first = players[0]
            currentRound.second = players[1]
            currentRound.third = players[2]
            currentRound.fourth = players[3]
        }
        
        updateAnnouncement(player: currentGame.player1!, state: hasAnnouncedPlayer1)
        updateAnnouncement(player: currentGame.player2!, state: hasAnnouncedPlayer2)
        updateAnnouncement(player: currentGame.player3!, state: hasAnnouncedPlayer3)
        updateAnnouncement(player: currentGame.player4!, state: hasAnnouncedPlayer4)

        applyDoubleWin()
        if !editMode {
            currentGame.addRound(addedRound: currentRound)
            currentRound = Round()
            
        }
        currentGame.reCount()
    }
    
    
    // Build ranking list for all four players based on currentRound's placements
    private func buildRankingList() -> [Int] {
        // Ensure players array has 4 entries corresponding to currentGame players
        let roundOrder: [Profile?] = [
            currentRound.first,
            currentRound.second,
            currentRound.third,
            currentRound.fourth
        ]
        // For each player in `players`, determine their rank by matching id in roundOrder
        return players.map { player in
            guard let player else { return 0 }
            if let idx = roundOrder.firstIndex(where: { $0?.id == player.id }) {
                return idx + 1 // ranks are 1-based
            }
            return 0 // not ranked yet
        }
    }
    
    private var hasDoubleWinTeam1: Bool {
        /*guard
            players.count >= 2,
            let first = players[0],
            let second = players[1],
            let team1 = currentGame.team1
        else {
            return false
        }

        return team1.list.contains(where: { $0.id == first.id }) &&
               team1.list.contains(where: { $0.id == second.id })*/
        
        if (currentRound.first == currentGame.team1?.list[0] && currentRound.second == currentGame.team1?.list[1]) || (currentRound.first == currentGame.team1?.list[1] && currentRound.second == currentGame.team1?.list[0]){
            return true
        }
        return false
    }

    private var hasDoubleWinTeam2: Bool {
        /*guard
            players.count >= 2,
            let first = players[0],
            let second = players[1],
            let team2 = currentGame.team2
        else {
            return false
        }

        return team2.list.contains(where: { $0.id == first.id }) &&
               team2.list.contains(where: { $0.id == second.id })*/
        if (currentRound.first == currentGame.team2?.list[0] && currentRound.second == currentGame.team2?.list[1]) || (currentRound.first == currentGame.team2?.list[1] && currentRound.second == currentGame.team2?.list[0]){
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack {
                    HStack {
                        GlassEffectContainer {
                            VStack(alignment: .leading) {
                                Text("Team 1")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.accentColor)
                                VStack {
                                    PlayerContainer(player: currentGame.player1 ?? Profile(),team:currentGame.team1 ?? Team(), hasAnnounced: $hasAnnouncedPlayer1, bombNumber: $currentRound.firstBombs,currentGame:$currentGame)
                                    PlayerContainer(player: currentGame.player2 ?? Profile(),team:currentGame.team1 ?? Team(), hasAnnounced: $hasAnnouncedPlayer2, bombNumber: $currentRound.secondBombs,currentGame:$currentGame)
                                }
                                .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Team 2")
                                .font(.title2)
                                .fontWeight(.bold)
                            VStack {
                                PlayerContainer(player: currentGame.player3 ?? Profile(),team:currentGame.team2 ?? Team(), hasAnnounced: $hasAnnouncedPlayer3, bombNumber: $currentRound.thirdBombs,currentGame:$currentGame)
                                PlayerContainer(player: currentGame.player4 ?? Profile(),team:currentGame.team2 ?? Team(), hasAnnounced: $hasAnnouncedPlayer4, bombNumber: $currentRound.fourthBombs,currentGame:$currentGame)
                            }
                            .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                        }
                    }
                    
                    HStack {
                        Text("Placement")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        Spacer()
                    }.zIndex(1 )
                    if dragMode == true{
                        List {
                            
                            ForEach(Array(players.enumerated()), id: \.element?.id) { index, player in
                                let golden = isGolden(index: index)
                                
                                
                                
                                HStack {
                                    Text("\(index + 1).")
                                        .fontWeight(.bold)
                                        .foregroundStyle(golden ? Color.accentColor : Color.primary)
                                    
                                    Text(player?.name ?? "Unknown")
                                    Spacer()
                                }
                            }
                            .onMove(perform: move)
                        }
                        .environment(\.editMode, .constant(.active))
                     
                        .frame(height: 250)
                        .scrollDisabled(true)
                        .padding(.top, -40)
                        .zIndex(0)
                    }else{
                        List {
                            
                            ForEach(Array(players.enumerated()), id: \.element?.id) { index, player in
                                let golden = isGolden2(index: index)
                                
                                
                                
                                HStack {
                                    Button{
                                        if hasPushedList[index] == false{
                                            counter += 1
                                            rankingList[index] = counter
                                            hasPushedList[index] = true
                                            if rankingList.allSatisfy({ $0 != 0 }){

                                                if let i1 = rankingList.firstIndex(of: 1) {
                                                    currentRound.first = players[i1]
                                                }

                                                if let i2 = rankingList.firstIndex(of: 2) {
                                                    currentRound.second = players[i2]
                                                }

                                                if let i3 = rankingList.firstIndex(of: 3) {
                                                    currentRound.third = players[i3]
                                                }

                                                if let i4 = rankingList.firstIndex(of: 4) {
                                                    currentRound.fourth = players[i4]
                                                }
                                            }
                                        }else if hasPushedList[index] == true{
                                            counter = 0
                                            rankingList = [0,0,0,0]
                                            hasPushedList = [false,false,false,false]
                                            currentRound.first = nil
                                            currentRound.second = nil
                                            currentRound.third = nil
                                            currentRound.fourth = nil
                                            
                                        }
                                        
                                        
                                    }label:{
                                        HStack{
                                            Text("\(rankingList[index]).").foregroundStyle(rankingList[index] == 0 ? Color.secondary : golden ? Color.green : Color.primary)
                                                .fontWeight(.bold)
                                                
                                            
                                            Text(player?.name ?? "Unknown")
                                            Spacer()
                                        }
                                    }.foregroundStyle(Color.primary)
                                }
                            }
                     
                        }
            
                   
                        .frame(height: 250)
                        .scrollDisabled(true)
                        .padding(.top, -40)
                        .zIndex(0)
                    }
                    
                    VStack {
                        HStack {
                            Text("Points 1")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Text("Points 2").font(.title2)
                                .fontWeight(.bold)
                        }.padding(.trailing,20)
                        VStack(alignment: .leading) {
                            HStack {
                                
                                Text("\(displayTeam1Points)").font(.title2)
                                    .fontWeight(.bold).foregroundStyle(Color.accentColor)
                                
                                if hasDoubleWinTeam1 || hasDoubleWinTeam2 {
                                    Spacer()
                                    Text("Double Win!").foregroundStyle(Color.green)
                                    
                                }
                                Spacer()
                                
                           
                                Text("\(displayTeam2Points)").font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            
                            Slider(
                                value: Binding(
                                    get: {
                                        if hasDoubleWinTeam1 {
                                            return 100
                                        }else if hasDoubleWinTeam2{
                                            return 0
                                        }
                                        return Double(currentRound.tichuPointsTeam1)
                                    },
                                    set: { newValue in
                                        guard !hasDoubleWinTeam1 else { return }
                                        currentRound.tichuPointsTeam1 = Int(newValue)
                                        currentRound.tichuPointsTeam2 = 100 - Int(newValue)
                                    }
                                ),
                                in: -25...125,
                                step: 5
                            )
                            .disabled(hasDoubleWinTeam1 || hasDoubleWinTeam2)
                            .padding(.horizontal, 30)
                        }
                        .padding(10)
                        .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
                        .padding(.trailing, 15)
                    }
                    .padding(.leading, 20)
                    .padding(.top, -10)
                }
                .navigationTitle(editMode == true ? "Edit Round \(roundIndex ?? -69420)" :"Add Round")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            showAddRoundsSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            saveRound()
                            showAddRoundsSheet = false
                        }.disabled(dragMode == true ? false : !rankingList.allSatisfy({ $0 != 0 }))
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .onAppear {
                if editMode {
                    players = [
                        currentGame.player1,
                        currentGame.player2,
                        currentGame.player3,
                        currentGame.player4,
                    ]
                    hasPushedList = [true,true,true,true]
                    rankingList = buildRankingList()
                    counter = rankingList.filter { $0 != 0 }.count
                }else{
                    players = [
                        currentGame.player1,
                        currentGame.player2,
                        currentGame.player3,
                        currentGame.player4
                    ]
                }

            
                hasAnnouncedPlayer1 = announcement(for: currentGame.player1)
                hasAnnouncedPlayer2 = announcement(for: currentGame.player2)
                hasAnnouncedPlayer3 = announcement(for: currentGame.player3)
                hasAnnouncedPlayer4 = announcement(for: currentGame.player4)
            }
        }
    }
}

#Preview {
    AddRoundSheetView(
        showAddRoundsSheet: .constant(true),
        currentGame: .constant(exampleGame),
        currentRound: .constant(exampleRound6),
        editMode: false,
        roundIndex: nil
    )
}

