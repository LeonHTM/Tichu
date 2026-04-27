//
//  exampleData.swift
//  Tichu
//
//  Created by Leon on 24.04.2026.
//

import SwiftUI




let exampleProfiles: [profile] = [
    exampleLeon,
    exampleSorin,
    exampleJo,
    exampleLuis,
   

    profile(
        name: "Beta",
        imageData: UIImage(named: "pfp_Beta")!.jpegData(compressionQuality: 1)!,
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
        imageData: UIImage(named: "pfp_Delta")!.jpegData(compressionQuality: 1)!,
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
        imageData: UIImage(named: "pfp_Alpha")!.jpegData(compressionQuality: 1)!,
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
        imageData: UIImage(named: "pfp_Gamma")!.jpegData(compressionQuality: 1)!,
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
        name: "Maximilian SuperGau",
        imageData: UIImage(named: "pfp_Max")!.jpegData(compressionQuality: 1)!,
        isFriend: true,
        elo: 2500,
        winnerPercentage: 95,
        tichuMaster: 45.2,
        visionary: 92,
        addict: 1543,
        teamplayer: 55,
        announcer: 74,
        saboteur: 55,
        gambler: 1,
        bigGambler: 99,
        bomber: 92
    ),
    profile(
        name: "Sonja Penner",
        imageData: UIImage(named: "pfp_Max")!.jpegData(compressionQuality: 1)!,
        isFriend: true,
        elo: 2500000,
        winnerPercentage: 905,
        tichuMaster: 450.2,
        visionary: 920,
        addict: 15403,
        teamplayer: 550,
        announcer: 704,
        saboteur: 550,
        gambler: 902,
        bigGambler: 909,
        bomber: 100
    )
    
]










let exampleProfilesReduced: [profile] = [

    profile(
        name: "Beta",
        imageData: UIImage(named: "pfp_Beta")!.jpegData(compressionQuality: 1)!,
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
        imageData: UIImage(named: "pfp_Delta")!.jpegData(compressionQuality: 1)!,
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
        imageData: UIImage(named: "pfp_Alpha")!.jpegData(compressionQuality: 1)!,
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
        imageData: UIImage(named: "pfp_Gamma")!.jpegData(compressionQuality: 1)!,
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


let exampleLeon: profile = profile(
    name: "Leon",
    imageData: UIImage(named: "pfp_Leon")!.jpegData(compressionQuality: 1)!,
    isFriend: true,
    elo: 887,
    winnerPercentage: 31,
    tichuMaster: 9.6,
    visionary: 68,
    addict: 70,
    teamplayer: 8,
    announcer: 22,
    saboteur: 27,
    gambler: 71,
    bigGambler: 63,
    bomber: 5
)

let exampleLuis: profile = profile(
    name: "Luis",
    imageData: UIImage(named: "pfp_Luis")!.jpegData(compressionQuality: 1)!,
    isFriend: true,
    elo: 983,
    winnerPercentage: 61,
    tichuMaster: 16.7,
    visionary: 78,
    addict: 67,
    teamplayer: 12,
    announcer: 30,
    saboteur: 27,
    gambler: 74,
    bigGambler: 63,
    bomber: 3
)

let exampleSorin: profile = profile(
    name: "Sorin",
    imageData: UIImage(named: "pfp_Sorin")!.jpegData(compressionQuality: 1)!,
    isFriend: true,
    elo: 983,
    winnerPercentage: 58,
    tichuMaster: 12.3,
    visionary: 61,
    addict: 67,
    teamplayer: 13,
    announcer: 22,
    saboteur: 33,
    gambler: 86,
    bigGambler: 58,
    bomber: 4
)

let exampleJo: profile = profile(
    name: "Jo",
    imageData: UIImage(named: "pfp_Jo")!.jpegData(compressionQuality: 1)!,
    isFriend: true,
    elo: 1016,
    winnerPercentage: 49,
    tichuMaster: 7.8,
    visionary: 56,
    addict: 67,
    teamplayer: 10,
    announcer: 19,
    saboteur: 30,
    gambler: 73,
    bigGambler: 57,
    bomber: 3
)








let emptyProfile: profile = profile(name: nil, imageData: nil, isFriend: false)

let guestProfile: profile = profile(name: "Guest", imageData: nil, isFriend: false)

let exampleGame = tichuGame(
    player1: exampleLuis,
    player2: exampleJo,
    player3: exampleSorin,
    player4: exampleLeon,
    rounds: [
        //Luis angesagt und geschafft 50/50
        round(
            first:exampleLuis,
            second:exampleSorin,
            third:exampleLeon,
            fourth:exampleJo,
            player1Bombs:0,
            player2Bombs:0,
            player3Bombs:0,
            player4Bombs:0,
            tichuPointsTeam1: 50,
            tichuPointsTeam2:50,
            roundPointsTeam1: 100,
            roundPointsTeam2: 0,
            doubleWinTeam1:false,
            doubleWinTeam2: false,
            hasAnnouncedTichu: [exampleLuis],
            hasAnnouncedBigTichu: [],
            hasAnnouncedPingu: []
            
            
        ),
        //Leon & Sorin Doppelsieg mit zwei Bomben
        round(
            first:exampleLeon,
            second:exampleSorin,
            third:exampleLuis,
            fourth:exampleJo,
            player1Bombs:0,
            player2Bombs:0,
            player3Bombs:1,
            player4Bombs:1,
            tichuPointsTeam1: 0,
            tichuPointsTeam2:100,
            roundPointsTeam1: 0,
            roundPointsTeam2: 100,
            doubleWinTeam1:false,
            doubleWinTeam2: true,
            hasAnnouncedTichu: [],
            hasAnnouncedBigTichu: [],
            hasAnnouncedPingu: []
            
            
        ),
        //-25,125
        round(
            first:exampleLuis,
            second:exampleSorin,
            third:exampleLeon,
            fourth:exampleJo,
            player1Bombs:0,
            player2Bombs:0,
            player3Bombs:0,
            player4Bombs:0,
            tichuPointsTeam1: -25,
            tichuPointsTeam2:125,
            roundPointsTeam1: 0,
            roundPointsTeam2: 0,
            doubleWinTeam1:false,
            doubleWinTeam2: false,
            hasAnnouncedTichu: [],
            hasAnnouncedBigTichu: [],
            hasAnnouncedPingu: [],
            
            
        ),
        //Sorin und Jo beide Biggie
        round(
            first:exampleJo,
            second:exampleSorin,
            third:exampleLuis,
            fourth:exampleLeon,
            player1Bombs:0,
            player2Bombs:0,
            player3Bombs:0,
            player4Bombs:0,
            tichuPointsTeam1: 75,
            tichuPointsTeam2:25,
            roundPointsTeam1: 200,
            roundPointsTeam2: -200,
            doubleWinTeam1:true,
            doubleWinTeam2: false,
            hasAnnouncedTichu: [],
            hasAnnouncedBigTichu: [exampleJo,exampleSorin],
            hasAnnouncedPingu: [],
       
            
        ),
        round(
            //Biggie Doppelsieg Leon&Sorin
            first:exampleLeon,
            second:exampleSorin,
            third:exampleLuis,
            fourth:exampleJo,
            player1Bombs:1,
            player2Bombs:1,
            player3Bombs:1,
            player4Bombs:1,
            tichuPointsTeam1: 0,
            tichuPointsTeam2:100,
            roundPointsTeam1: 0,
            roundPointsTeam2: 300,
            doubleWinTeam1:false,
            doubleWinTeam2: true,
            hasAnnouncedTichu: [],
            hasAnnouncedBigTichu: [exampleLeon],
            hasAnnouncedPingu: [],
            
        )
    ]
    
)
