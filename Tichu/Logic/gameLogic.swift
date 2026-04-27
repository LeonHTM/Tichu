//
//  gameLogic.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI


struct team:Identifiable {
    let id = UUID()
    var list: [profile]

    init(list: [profile]) {
        precondition(list.count <= 2, "Maximum 2 profiles allowed")
        self.list = list
    }
}


struct tichuGame:Identifiable{
    //Team 1
    let id = UUID()
    var team1: team
    var player1: profile?
    var player2: profile?
    var currentPointsTeam1: Int
    
    //Team 2
    var team2: team
    var player3: profile?
    var player4: profile?
    var currentPointsTeam2: Int
    
    var rounds: [round]
    var winner: team?
    
    init(player1: profile,player2: profile,player3: profile,player4: profile,rounds: [round]){
        self.player1 = player1
        self.player2 = player2
        self.player3 = player3
        self.player4 = player4
        
        
        self.team1 = team(list: [
                    player1,
                    player2
                ])

        self.team2 = team(list: [
                    player3,
                    player4
                ])
        self.rounds = rounds
        
        self.currentPointsTeam1 = 0
        self.currentPointsTeam2 = 0 
        
    }
    
}




struct round:Identifiable {
    var id = UUID()
    var first: profile
    var second: profile
    var third: profile
    var fourth: profile

    var player1Bombs: Int
    var player2Bombs: Int
    var player3Bombs: Int
    var player4Bombs: Int

    var tichuPointsTeam1: Int
    var tichuPointsTeam2: Int
    
    var roundPointsTeam1: Int
    var roundPointsTeam2: Int
    
    var doubleWinTeam1: Bool
    var doubleWinTeam2: Bool

    var hasAnnouncedTichu: [profile]
    var hasAnnouncedBigTichu: [profile]
    var hasAnnouncedPingu: [profile]

    init(
        first: profile,
        second: profile,
        third: profile,
        fourth: profile,
        player1Bombs: Int,
        player2Bombs: Int,
        player3Bombs: Int,
        player4Bombs: Int,
        tichuPointsTeam1: Int,
        tichuPointsTeam2: Int,
        roundPointsTeam1: Int,
        roundPointsTeam2: Int,
        doubleWinTeam1: Bool,
        doubleWinTeam2: Bool,
        hasAnnouncedTichu: [profile],
        hasAnnouncedBigTichu: [profile],
        hasAnnouncedPingu: [profile]
        
    ) {

        //All players must be unique
        let players = [first, second, third, fourth]
        precondition(Set(players.map { $0.id }).count == 4,
                     "All players must be different")

        // Max 3 bombs per player
        precondition(player1Bombs <= 3 &&
                     player2Bombs <= 3 &&
                     player3Bombs <= 3 &&
                     player4Bombs <= 3,
                     "Max 3 bombs per player")

        //Tichupoints have to equal 100
        precondition(tichuPointsTeam1 + tichuPointsTeam2 == 100,
                     "Team points must sum to 100")

        
      
        
        self.first = first
        self.second = second
        self.third = third
        self.fourth = fourth

        self.player1Bombs = player1Bombs
        self.player2Bombs = player2Bombs
        self.player3Bombs = player3Bombs
        self.player4Bombs = player4Bombs

        self.tichuPointsTeam1 = tichuPointsTeam1
        self.tichuPointsTeam2 = tichuPointsTeam2
        
       

        self.hasAnnouncedTichu = hasAnnouncedTichu
        self.hasAnnouncedBigTichu = hasAnnouncedBigTichu
        self.hasAnnouncedPingu = hasAnnouncedPingu
        
        self.roundPointsTeam1 = roundPointsTeam1
        self.roundPointsTeam2 = roundPointsTeam2
        
        self.doubleWinTeam1 = doubleWinTeam1
        self.doubleWinTeam2 = doubleWinTeam2
    }
}
