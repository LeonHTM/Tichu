//
//  GameLogic.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//

import SwiftUI


struct Game: Identifiable, Decodable {
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
}

import Foundation

struct Round: Identifiable, Decodable {
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



