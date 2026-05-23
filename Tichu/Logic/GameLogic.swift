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
    var allow_pingus: Bool

    var team1_player1_id: Int?
    var team1_player2_id: Int?
    var team2_player1_id: Int?
    var team2_player2_id: Int?

    var current_points_team1: Int
    var current_points_team2: Int

    var winner: Int?
}

import Foundation

struct Round: Identifiable, Decodable {
    let id: Int
    var game_id: Int
    var round_order: Int

    var first_profile_id: Int?
    var second_profile_id: Int?
    var third_profile_id: Int?
    var fourth_profile_id: Int?

    var first_bombs: Int
    var second_bombs: Int
    var third_bombs: Int
    var fourth_bombs: Int

    var tichu_points_team1: Int
    var tichu_points_team2: Int

    var round_points_team1: Int
    var round_points_team2: Int

    var double_win_team1: Bool
    var double_win_team2: Bool

    var bool_win_round: Bool

    var announced_tichu: [Int]
    var announced_big_tichu: [Int]
    var announced_pingu: [Int]
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



