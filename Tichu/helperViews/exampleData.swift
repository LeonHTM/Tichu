//
//  exampleData.swift
//  Tichu
//
//  Created by Leon on 24.04.2026.
//

import SwiftUI



var exampleStatsDicEmpty: [String: playerStats] = [:]

//Example of userData as a List of profiles
var exampleProfiles: [profile] = [
    profile(
        name: "Leon",
        imageData: UIImage(named: "pfp_leon")!.jpegData(compressionQuality: 1)!,
        isFriend: true,
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

    profile(
        name: "Sorin",
        imageData: UIImage(named: "pfp_sorin")!.jpegData(compressionQuality: 1)!,
        isFriend: true,
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
    ),

    profile(
        name: "Jo",
        imageData: UIImage(named: "pfp_jo")!.jpegData(compressionQuality: 1)!,
        isFriend: true,
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

    profile(
        name: "Luis",
        imageData: UIImage(named: "pfp_luis")!.jpegData(compressionQuality: 1)!,
        isFriend: true,
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

    profile(
        name: "Beta",
        imageData: UIImage(named: "pfp_beta")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    
    profile(
        name: "Delta",
        imageData: UIImage(named: "pfp_delta")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    
    profile(
        name: "Alpha",
        imageData: UIImage(named: "pfp_alpha")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    
    profile(
        name: "gamma",
        imageData: UIImage(named: "pfp_gamma")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    )
    
]


var exampleProfilesReduced: [profile] = [

    profile(
        name: "Beta",
        imageData: UIImage(named: "pfp_beta")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    
    profile(
        name: "Delta",
        imageData: UIImage(named: "pfp_delta")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    
    profile(
        name: "Alpha",
        imageData: UIImage(named: "pfp_alpha")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    
    profile(
        name: "gamma",
        imageData: UIImage(named: "pfp_gamma")!.jpegData(compressionQuality: 1)!,
        isFriend: false,
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
    )
    
]









var emptyProfile: profile = profile(name: nil, imageData: nil, isFriend: false)

var guestProfile: profile = profile(name: "Guest", imageData: nil, isFriend: false)

