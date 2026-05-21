//
//  GameLogic.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI


struct Team: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var list: [Profile]

    init(list: [Profile] = [],name:String = "Unknown Team") {
        //If provided, must be exactly two
        precondition(list.isEmpty || list.count == 2, "If provided, exactly 2 Profiles allowed")
        self.list = list
        self.name = name
    }

}


struct tichuGame: Identifiable {
    let id = UUID()
    let date: Date

    // Team 1
    var team1: Team?
    var player1: Profile?
    var player2: Profile?
    var currentPointsTeam1: Int

    // Team 2
    var team2: Team?
    var player3: Profile?
    var player4: Profile?
    var currentPointsTeam2: Int
    
    var allowPingus: Bool
    
    var target: Int
    var Rounds: [Round]
    var winRounds: [Round]
    var winner: Team?

    init(
        allowPingus: Bool = true,
        player1: Profile? = nil,
        player2: Profile? = nil,
        player3: Profile? = nil,
        player4: Profile? = nil,
        Rounds: [Round] = [],
        winRounds: [Round] = [],
        target: Int = 1000
    ) {
        self.player1 = player1
        self.player2 = player2
        self.player3 = player3
        self.player4 = player4
        
        self.target = target
        self.date = Date()

        // Build teams only when both players are present
        if let p1 = player1, let p2 = player2 {
            self.team1 = Team(list: [p1, p2],name:"Team 1")
        } else {
            self.team1 = nil
        }

        if let p3 = player3, let p4 = player4 {
            self.team2 = Team(list: [p3, p4],name:"Team 2")
        } else {
            self.team2 = nil
        }

        self.Rounds = Rounds
        self.winRounds = winRounds
        self.currentPointsTeam1 = 0
        self.currentPointsTeam2 = 0
        self.allowPingus = allowPingus
    }

    mutating func addRound(addedRound: Round) {
        Rounds.append(addedRound)
        self.currentPointsTeam1 = self.currentPointsTeam1 + addedRound.tichuPointsTeam1 + addedRound.roundPointsTeam1
        self.currentPointsTeam2 = self.currentPointsTeam2 + addedRound.tichuPointsTeam2 + addedRound.roundPointsTeam2

        // Validate Team matching only when both game teams and Round teams are present
        if let gameTeam1 = self.team1, let gameTeam2 = self.team2, let rTeam1 = addedRound.team1, let rTeam2 = addedRound.team2 {
            precondition(rTeam1 == gameTeam1 && rTeam2 == gameTeam2, "Teams should match up")
        }
    }

    mutating func addRound(addedRounds: [Round]) {
        for r in addedRounds {
            if let gameTeam1 = self.team1, let gameTeam2 = self.team2, let rTeam1 = r.team1, let rTeam2 = r.team2 {
                precondition(rTeam1 == gameTeam1 && rTeam2 == gameTeam2, "Teams should match up")
            }

            Rounds.append(r)

            currentPointsTeam1 += r.tichuPointsTeam1 + r.roundPointsTeam1
            currentPointsTeam2 += r.tichuPointsTeam2 + r.roundPointsTeam2
        }
    }
    
    mutating func reCount(){
        // Reset state
        self.currentPointsTeam1 = 0
        self.currentPointsTeam2 = 0
        self.winner = nil
        self.winRounds.removeAll()

        // Helper to evaluate the "still OK" condition (game not finished yet)
        func conditionIsTrue(_ t1: Int, _ t2: Int, _ target: Int) -> Bool {
            // Condition is true while neither side has reached target with a lead
            return !((t1 >= target && t1 > t2) || (t2 >= target && t2 > t1))
        }

        var stillTrue = true

        for round in self.Rounds {
            // Apply this round's points
            self.currentPointsTeam1 += (round.tichuPointsTeam1 + round.roundPointsTeam1)
            self.currentPointsTeam2 += (round.tichuPointsTeam2 + round.roundPointsTeam2)

            // Always append the current round once we process it
            self.winRounds.append(round)

            // Evaluate condition after applying this round
            let cond = conditionIsTrue(self.currentPointsTeam1, self.currentPointsTeam2, self.target)

            if stillTrue && !cond {
                // This is the first round where the condition turns false.
                // We've already appended it, now determine winner and stop.
                if self.currentPointsTeam1 >= self.target && self.currentPointsTeam1 > self.currentPointsTeam2 {
                    self.winner = self.team1
                } else if self.currentPointsTeam2 >= self.target && self.currentPointsTeam2 > self.currentPointsTeam1 {
                    self.winner = self.team2
                }
                break
            }

            stillTrue = cond
        }

        // If the loop finished without breaking, check if a winner exists based on totals.
        if self.winner == nil {
            if self.currentPointsTeam1 >= self.target && self.currentPointsTeam1 > self.currentPointsTeam2 {
                self.winner = self.team1
            } else if self.currentPointsTeam2 >= self.target && self.currentPointsTeam2 > self.currentPointsTeam1 {
                self.winner = self.team2
            }
        }
    }
    
    
    
}



struct Round: Identifiable {
    var id = UUID()
    var first: Profile?
    var second: Profile?
    var third: Profile?
    var fourth: Profile?

    var team1: Team?
    var team2: Team?

    var firstBombs: Int
    var secondBombs: Int
    var thirdBombs: Int
    var fourthBombs: Int

    var tichuPointsTeam1: Int
    var tichuPointsTeam2: Int

    var roundPointsTeam1: Int
    var roundPointsTeam2: Int

    var doubleWinTeam1: Bool
    var doubleWinTeam2: Bool

    var hasAnnouncedTichu: [Profile]
    var hasAnnouncedBigTichu: [Profile]
    var hasAnnouncedPingu: [Profile]

    init(
        first: Profile? = nil,
        second: Profile? = nil,
        third: Profile? = nil,
        fourth: Profile? = nil,
        firstBombs: Int = 0,
        secondBombs: Int = 0,
        thirdBombs: Int = 0,
        fourthBombs: Int = 0,
        tichuPointsTeam1: Int = 50,
        tichuPointsTeam2: Int = 50,
        roundPointsTeam1: Int = 0,
        roundPointsTeam2: Int = 0,
        doubleWinTeam1: Bool = false,
        doubleWinTeam2: Bool = false,
        hasAnnouncedTichu: [Profile] = [],
        hasAnnouncedBigTichu: [Profile] = [],
        hasAnnouncedPingu: [Profile] = [],
        team1: Team? = nil,
        team2: Team? = nil
    ) {
        // Validate only when data is present

        // All players must be unique if all four are present
        if let f = first, let s = second, let t = third, let fo = fourth {
            let players = [f, s, t, fo]
            precondition(Set(players.map { $0.id }).count == 4, "All players must be different")
        }

        // Max 3 bombs per player (always applies)
        precondition(firstBombs <= 3 && secondBombs <= 3 && thirdBombs <= 3 && fourthBombs <= 3, "Max 3 bombs per player")

        // Tichu points must sum to 100 only if both sides are non-zero-sum configured; with defaults we enforce 50/50
        precondition(tichuPointsTeam1 + tichuPointsTeam2 == 100, "Team points must sum to 100")

        // A player can only announce one type, validate uniqueness across announcements
        let allAnnouncements = hasAnnouncedTichu + hasAnnouncedBigTichu + hasAnnouncedPingu
        precondition(Set(allAnnouncements.map { $0.id }).count == allAnnouncements.count, "A player can only announce either a Tichu or Big Tichu or Pingu")

        // Double win checks only when corresponding Team and finishing players are present
        if doubleWinTeam1, let team1{
            if let f = first, let s = second {
                let team1PlayerIDs = Set(team1.list.map { $0.id })
                precondition(team1PlayerIDs.contains(f.id) && team1PlayerIDs.contains(s.id), "doubleWinTeam1 can only be true if first and second are both in team1")
            }
            
        }

        if doubleWinTeam2, let team2 {
            if let f = first, let s = second {
                let team2PlayerIDs = Set(team2.list.map { $0.id })
                precondition(team2PlayerIDs.contains(f.id) && team2PlayerIDs.contains(s.id), "doubleWinTeam2 can only be true if first and second are both in team2")
            }
            
         
        }
        


        self.first = first
        self.second = second
        self.third = third
        self.fourth = fourth

        self.firstBombs = firstBombs
        self.secondBombs = secondBombs
        self.thirdBombs = fourthBombs
        self.fourthBombs = fourthBombs

        self.tichuPointsTeam1 = tichuPointsTeam1
        self.tichuPointsTeam2 = tichuPointsTeam2

        self.hasAnnouncedTichu = hasAnnouncedTichu
        self.hasAnnouncedBigTichu = hasAnnouncedBigTichu
        self.hasAnnouncedPingu = hasAnnouncedPingu

        self.roundPointsTeam1 = roundPointsTeam1
        self.roundPointsTeam2 = roundPointsTeam2

        self.doubleWinTeam1 = doubleWinTeam1
        self.doubleWinTeam2 = doubleWinTeam2

        self.team1 = team1
        self.team2 = team2
    }
}

enum tichuGameTarget: Int, CaseIterable, Identifiable {
    case xs = 250
    case s = 500
    case l = 750
    case xl = 1000
    case xxl = 2000
    case xxxl = 5000
    case xxxxl = 10000
    
    var id: Int { self.rawValue }
}




//UPDATE GAME TO STORE ONLY ID TO UPDATE ON CHANGE

/*import SwiftUI
 
 struct Team: Identifiable, Equatable {
     let id = UUID()
     let name: String
     var playerIds: [Int]

     init(playerIds: [Int] = [], name: String = "Unknown Team") {
         precondition(playerIds.isEmpty || playerIds.count == 2, "If provided, exactly 2 player IDs allowed")
         self.playerIds = playerIds
         self.name = name
     }

     static func == (lhs: Team, rhs: Team) -> Bool {
         lhs.playerIds == rhs.playerIds
     }
 }

 struct tichuGame: Identifiable {
     let id = UUID()
     let date: Date

     // Team 1
     var team1: Team?
     var player1Id: Int?
     var player2Id: Int?
     var currentPointsTeam1: Int

     // Team 2
     var team2: Team?
     var player3Id: Int?
     var player4Id: Int?
     var currentPointsTeam2: Int

     var allowPingus: Bool
     var target: Int
     var Rounds: [Round]
     var winRounds: [Round]
     var winnerId: Int?  // team id

     init(
         allowPingus: Bool = true,
         player1Id: Int? = nil,
         player2Id: Int? = nil,
         player3Id: Int? = nil,
         player4Id: Int? = nil,
         Rounds: [Round] = [],
         winRounds: [Round] = [],
         target: Int = 1000
     ) {
         self.player1Id = player1Id
         self.player2Id = player2Id
         self.player3Id = player3Id
         self.player4Id = player4Id

         self.target = target
         self.date = Date()

         if let p1 = player1Id, let p2 = player2Id {
             self.team1 = Team(playerIds: [p1, p2], name: "Team 1")
         } else {
             self.team1 = nil
         }

         if let p3 = player3Id, let p4 = player4Id {
             self.team2 = Team(playerIds: [p3, p4], name: "Team 2")
         } else {
             self.team2 = nil
         }

         self.Rounds = Rounds
         self.winRounds = winRounds
         self.currentPointsTeam1 = 0
         self.currentPointsTeam2 = 0
         self.allowPingus = allowPingus
         self.winnerId = nil
     }

     // Helper to get profiles from NetworkService
     func player1(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == player1Id } }
     func player2(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == player2Id } }
     func player3(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == player3Id } }
     func player4(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == player4Id } }

     var isReady: Bool {
         player2Id != nil && player3Id != nil && player4Id != nil
     }

     mutating func addRound(addedRound: Round) {
         Rounds.append(addedRound)
         self.currentPointsTeam1 += addedRound.tichuPointsTeam1 + addedRound.roundPointsTeam1
         self.currentPointsTeam2 += addedRound.tichuPointsTeam2 + addedRound.roundPointsTeam2
     }

     mutating func reCount() {
         self.currentPointsTeam1 = 0
         self.currentPointsTeam2 = 0
         self.winnerId = nil
         self.winRounds.removeAll()

         func conditionIsTrue(_ t1: Int, _ t2: Int, _ target: Int) -> Bool {
             return !((t1 >= target && t1 > t2) || (t2 >= target && t2 > t1))
         }

         var stillTrue = true

         for round in self.Rounds {
             self.currentPointsTeam1 += round.tichuPointsTeam1 + round.roundPointsTeam1
             self.currentPointsTeam2 += round.tichuPointsTeam2 + round.roundPointsTeam2
             self.winRounds.append(round)

             let cond = conditionIsTrue(self.currentPointsTeam1, self.currentPointsTeam2, self.target)

             if stillTrue && !cond {
                 if self.currentPointsTeam1 >= self.target && self.currentPointsTeam1 > self.currentPointsTeam2 {
                     self.winnerId = team1?.id.hashValue
                 } else if self.currentPointsTeam2 >= self.target && self.currentPointsTeam2 > self.currentPointsTeam1 {
                     self.winnerId = team2?.id.hashValue
                 }
                 break
             }
             stillTrue = cond
         }
     }
 }

 struct Round: Identifiable {
     var id = UUID()
     var firstId: Int?
     var secondId: Int?
     var thirdId: Int?
     var fourthId: Int?

     var team1: Team?
     var team2: Team?

     var firstBombs: Int
     var secondBombs: Int
     var thirdBombs: Int
     var fourthBombs: Int

     var tichuPointsTeam1: Int
     var tichuPointsTeam2: Int

     var roundPointsTeam1: Int
     var roundPointsTeam2: Int

     var doubleWinTeam1: Bool
     var doubleWinTeam2: Bool

     var announcedTichuIds: [Int]
     var announcedBigTichuIds: [Int]
     var announcedPinguIds: [Int]

     init(
         firstId: Int? = nil,
         secondId: Int? = nil,
         thirdId: Int? = nil,
         fourthId: Int? = nil,
         firstBombs: Int = 0,
         secondBombs: Int = 0,
         thirdBombs: Int = 0,
         fourthBombs: Int = 0,
         tichuPointsTeam1: Int = 50,
         tichuPointsTeam2: Int = 50,
         roundPointsTeam1: Int = 0,
         roundPointsTeam2: Int = 0,
         doubleWinTeam1: Bool = false,
         doubleWinTeam2: Bool = false,
         announcedTichuIds: [Int] = [],
         announcedBigTichuIds: [Int] = [],
         announcedPinguIds: [Int] = [],
         team1: Team? = nil,
         team2: Team? = nil
     ) {
         precondition(firstBombs <= 3 && secondBombs <= 3 && thirdBombs <= 3 && fourthBombs <= 3, "Max 3 bombs per player")
         precondition(tichuPointsTeam1 + tichuPointsTeam2 == 100, "Team points must sum to 100")

         let allAnnouncements = announcedTichuIds + announcedBigTichuIds + announcedPinguIds
         precondition(Set(allAnnouncements).count == allAnnouncements.count, "A player can only announce one type")

         self.firstId = firstId
         self.secondId = secondId
         self.thirdId = thirdId
         self.fourthId = fourthId

         self.firstBombs = firstBombs
         self.secondBombs = secondBombs
         self.thirdBombs = thirdBombs
         self.fourthBombs = fourthBombs

         self.tichuPointsTeam1 = tichuPointsTeam1
         self.tichuPointsTeam2 = tichuPointsTeam2

         self.announcedTichuIds = announcedTichuIds
         self.announcedBigTichuIds = announcedBigTichuIds
         self.announcedPinguIds = announcedPinguIds

         self.roundPointsTeam1 = roundPointsTeam1
         self.roundPointsTeam2 = roundPointsTeam2

         self.doubleWinTeam1 = doubleWinTeam1
         self.doubleWinTeam2 = doubleWinTeam2

         self.team1 = team1
         self.team2 = team2
     }

     // Helper to get profiles from NetworkService
     func first(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == firstId } }
     func second(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == secondId } }
     func third(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == thirdId } }
     func fourth(from profiles: [Profile]) -> Profile? { profiles.first { $0.id == fourthId } }
 }

 enum tichuGameTarget: Int, CaseIterable, Identifiable {
     case xs = 250
     case s = 500
     case l = 750
     case xl = 1000
     case xxl = 2000
     case xxxl = 5000
     case xxxxl = 10000

     var id: Int { self.rawValue }
 }*/
