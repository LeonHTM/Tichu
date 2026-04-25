//
//  exampleData.swift
//  Tichu
//
//  Created by Leon on 24.04.2026.
//

import SwiftUI



var exampleStatsDicEmpty: [String: playerStats] = [:]

//Example of userData in a Dictionary
var exampleStatsDic: [String: playerStats] = [
    "Leon": playerStats(
        elo: 780,
        winnerPercentage: 62,
        tichuMaster: 4.5,
        visionary: 12,
        addict: 3,
        teamplayer: 8,
        announcer: 5,
        saboteur: 2,
        gambler: 10,
        bigGambler: 1,
        bomber: 0
    ),

    "Beta": playerStats(
        elo: 1000,
        winnerPercentage: 55,
        tichuMaster: 3.2,
        visionary: 9,
        addict: 6,
        teamplayer: 11,
        announcer: 4,
        saboteur: 3,
        gambler: 7,
        bigGambler: 2,
        bomber: 1
    ),

    "Luis": playerStats(
        elo: 1420,
        winnerPercentage: 71,
        tichuMaster: 5.8,
        visionary: 15,
        addict: 2,
        teamplayer: 10,
        announcer: 6,
        saboteur: 1,
        gambler: 12,
        bigGambler: 3,
        bomber: 0
    ),

    "Jo": playerStats(
        elo: 1690,
        winnerPercentage: 78,
        tichuMaster: 6.1,
        visionary: 18,
        addict: 1,
        teamplayer: 14,
        announcer: 7,
        saboteur: 2,
        gambler: 9,
        bigGambler: 4,
        bomber: 1
    ),

    "Sorin": playerStats(
        elo: 1200,
        winnerPercentage: 65,
        tichuMaster: 4.0,
        visionary: 10,
        addict: 4,
        teamplayer: 9,
        announcer: 3,
        saboteur: 2,
        gambler: 8,
        bigGambler: 1,
        bomber: 0
    )
]





var exampleProfiles: [Profile] = [
    Profile(name: "Leon", imageData: UIImage(named: "pfp_leon")!.jpegData(compressionQuality: 1)!,isFriend:true),
    Profile(name: "Sorin", imageData: UIImage(named: "pfp_sorin")!.jpegData(compressionQuality: 1)!,isFriend:true),
    Profile(name: "Jo", imageData: UIImage(named: "pfp_jo")!.jpegData(compressionQuality: 1)!,isFriend:true),
    Profile(name: "Luis", imageData: UIImage(named: "pfp_luis")!.jpegData(compressionQuality: 1)!,isFriend:true),
    Profile(name: "Alpha", imageData: UIImage(named: "pfp_alpha")!.jpegData(compressionQuality: 1)!,isFriend: false),
    Profile(name: "Beta", imageData: UIImage(named: "pfp_beta")!.jpegData(compressionQuality: 1)!,isFriend: false),
    Profile(name: "Gamma", imageData: UIImage(named: "pfp_gamma")!.jpegData(compressionQuality: 1)!,isFriend: false),
    Profile(name: "Delta", imageData: UIImage(named: "pfp_delta")!.jpegData(compressionQuality: 1)!,isFriend: false)
]

var exampleProfile: Profile = Profile(name: "Alpha", imageData: UIImage(named: "pfp_alpha")!.jpegData(compressionQuality: 1)!,isFriend: false)

var emptyProfile: Profile = Profile(name: nil, imageData: nil, isFriend: false)

var guestProfile: Profile = Profile(name: "Guest", imageData: nil, isFriend: false)

