//
//  gameLogic.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI


struct Team: Identifiable, Equatable {
    let id = UUID()
    var list: [profile]

    init(list: [profile] = []) {
        //If provided, must be exactly two
        precondition(list.isEmpty || list.count == 2, "If provided, exactly 2 profiles allowed")
        self.list = list
    }

    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.list[0].id == rhs.list[0].id && lhs.list[1].id == rhs.list[1].id
    }
}


struct tichuGame: Identifiable {
    let id = UUID()

    // Team 1
    var team1: Team?
    var player1: profile?
    var player2: profile?
    var currentPointsTeam1: Int

    // Team 2
    var team2: Team?
    var player3: profile?
    var player4: profile?
    var currentPointsTeam2: Int

    var Rounds: [Round]
    var winner: Team?

    init(
        player1: profile? = nil,
        player2: profile? = nil,
        player3: profile? = nil,
        player4: profile? = nil,
        Rounds: [Round] = []
    ) {
        self.player1 = player1
        self.player2 = player2
        self.player3 = player3
        self.player4 = player4

        // Build teams only when both players are present
        if let p1 = player1, let p2 = player2 {
            self.team1 = Team(list: [p1, p2])
        } else {
            self.team1 = nil
        }

        if let p3 = player3, let p4 = player4 {
            self.team2 = Team(list: [p3, p4])
        } else {
            self.team2 = nil
        }

        self.Rounds = Rounds
        self.currentPointsTeam1 = 0
        self.currentPointsTeam2 = 0
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
}



struct Round: Identifiable {
    var id = UUID()
    var first: profile?
    var second: profile?
    var third: profile?
    var fourth: profile?

    var team1: Team?
    var team2: Team?

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
        first: profile? = nil,
        second: profile? = nil,
        third: profile? = nil,
        fourth: profile? = nil,
        player1Bombs: Int = 0,
        player2Bombs: Int = 0,
        player3Bombs: Int = 0,
        player4Bombs: Int = 0,
        tichuPointsTeam1: Int = 50,
        tichuPointsTeam2: Int = 50,
        roundPointsTeam1: Int = 0,
        roundPointsTeam2: Int = 0,
        doubleWinTeam1: Bool = false,
        doubleWinTeam2: Bool = false,
        hasAnnouncedTichu: [profile] = [],
        hasAnnouncedBigTichu: [profile] = [],
        hasAnnouncedPingu: [profile] = [],
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
        precondition(player1Bombs <= 3 && player2Bombs <= 3 && player3Bombs <= 3 && player4Bombs <= 3, "Max 3 bombs per player")

        // Tichu points must sum to 100 only if both sides are non-zero-sum configured; with defaults we enforce 50/50
        precondition(tichuPointsTeam1 + tichuPointsTeam2 == 100, "Team points must sum to 100")

        // A player can only announce one type, validate uniqueness across announcements
        let allAnnouncements = hasAnnouncedTichu + hasAnnouncedBigTichu + hasAnnouncedPingu
        precondition(Set(allAnnouncements.map { $0.id }).count == allAnnouncements.count, "A player can only announce either a Tichu or Big Tichu or Pingu")

        // Double win checks only when corresponding Team and finishing players are present
        if doubleWinTeam1, let team1 {
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

        self.team1 = team1
        self.team2 = team2
    }
}

