//
//  GameLogic.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI


struct Game: Identifiable, Decodable, Equatable {
    let id: Int
    var date: Date

    var target: Int
    var allowPingus: Bool

    var team1Player1Id: Int?
    var team1Player2Id: Int?
    var team2Player1Id: Int?
    var team2Player2Id: Int?

    var currentPointsTeam1: Int
    var currentPointsTeam2: Int

    var winner: Int?
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }
}

import Foundation

struct Round: Identifiable, Decodable, Equatable {
    let id: Int
    var gameId: Int
    var roundOrder: Int

    var firstProfileId: Int?
    var secondProfileId: Int?
    var thirdProfileId: Int?
    var fourthProfileId: Int?

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

    var boolWinRound: Bool

    var announcedTichu: [Int]
    var announcedBigTichu: [Int]
    var announcedPingu: [Int]
    
    static func == (lhs: Round, rhs: Round) -> Bool {
        lhs.id == rhs.id &&
        lhs.firstProfileId == rhs.firstProfileId &&
        lhs.secondProfileId == rhs.secondProfileId &&
        lhs.thirdProfileId == rhs.thirdProfileId &&
        lhs.fourthProfileId == rhs.fourthProfileId &&
        lhs.firstBombs == rhs.firstBombs &&
        lhs.secondBombs == rhs.secondBombs &&
        lhs.thirdBombs == rhs.thirdBombs &&
        lhs.fourthBombs == rhs.fourthBombs &&
        lhs.tichuPointsTeam1 == rhs.tichuPointsTeam1 &&
        lhs.tichuPointsTeam2 == rhs.tichuPointsTeam2 &&
        lhs.doubleWinTeam1 == rhs.doubleWinTeam1 &&
        lhs.doubleWinTeam2 == rhs.doubleWinTeam2 &&
        lhs.announcedTichu == rhs.announcedTichu &&
        lhs.announcedBigTichu == rhs.announcedBigTichu &&
        lhs.announcedPingu == rhs.announcedPingu
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



struct EloHistoryEntry: Identifiable, Codable {
    var id: Int
    var gameId: Int?
    var eloChange: Double
    var changedAt: Date?
}
