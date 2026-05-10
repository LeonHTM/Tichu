//
//  exampleData.swift
//  Tichu
//
//  Created by Leon on 24.04.2026.
//

import SwiftUI




let exampleProfiles: [Profile] = [
    exampleLeon,
    exampleSorin,
    exampleJo,
    exampleLuis,
   

    Profile(
        name: "Beta",
        imageData: UIImage(named: "pfp_Beta")?.jpegData(compressionQuality: 1),
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
        pinguGambler:12,
        bomber: 1
    ),
    
    Profile(
        name: "Delta",
        imageData: UIImage(named: "pfp_Delta")?.jpegData(compressionQuality: 1),
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
        pinguGambler:0,
        bomber: 1
    ),
    
    Profile(
        name: "Alpha",
        imageData: UIImage(named: "pfp_Alpha")?.jpegData(compressionQuality: 1),
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
        pinguGambler:11,
        bomber: 1
    ),
    
    Profile(
        name: "gamma",
        imageData: UIImage(named: "pfp_Gamma")?.jpegData(compressionQuality: 1),
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
        pinguGambler:83,
        bomber: 1
    ),
    Profile(
        name: "Maximilian SuperGau",
        imageData: UIImage(named: "pfp_Max")?.jpegData(compressionQuality: 1),
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
        pinguGambler:12,
        bomber: 92
    ),
    Profile(
        name: "Sonja Penner",
        imageData: UIImage(named: "pfp_Sonja")?.jpegData(compressionQuality: 1),
        isFriend: true,
        elo: 2500,
        winnerPercentage: 31,
        tichuMaster: 21.293811,
        visionary: 47,
        addict: 1,
        teamplayer: 45,
        announcer: 23,
        saboteur: 56,
        gambler: 78,
        bigGambler: 78,
        pinguGambler:11,
        bomber: 10
    )
    
]


let exampleProfilesReduced: [Profile] = [

    Profile(
        name: "Beta",
        imageData: UIImage(named: "pfp_Beta")?.jpegData(compressionQuality: 1),
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
        pinguGambler:12,
        bomber: 1
    ),
    
    Profile(
        name: "Delta",
        imageData: UIImage(named: "pfp_Delta")?.jpegData(compressionQuality: 1),
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
        pinguGambler:66,
        bomber: 1
    ),
    
    Profile(
        name: "Alpha",
        imageData: UIImage(named: "pfp_Alpha")?.jpegData(compressionQuality: 1),
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
        pinguGambler:33,
        bomber: 1
    ),
    
    Profile(
        name: "gamma",
        imageData: UIImage(named: "pfp_Gamma")?.jpegData(compressionQuality: 1),
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
        pinguGambler:82,
        bomber: 1
    )
   
    
]


let exampleLeon: Profile = Profile(
    name: "Leon",
    imageData: UIImage(named: "pfp_Leon")?.jpegData(compressionQuality: 1),
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
    pinguGambler:91,
    bomber: 5
)

let exampleLuis: Profile = Profile(
    name: "Luis",
    imageData: UIImage(named: "pfp_Luis")?.jpegData(compressionQuality: 1),
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
    pinguGambler:100,
    bomber: 3
)

let exampleSorin: Profile = Profile(
    name: "Sorin",
    imageData: UIImage(named: "pfp_Sorin")?.jpegData(compressionQuality: 1),
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
    pinguGambler:69,
    bomber: 4
)

let exampleJo: Profile = Profile(
    name: "Jo",
    imageData: UIImage(named: "pfp_Jo")?.jpegData(compressionQuality: 1),
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
    pinguGambler:75,
    bomber: 3
)




let guest2Profile: Profile = Profile(name: "Guest 2", imageData: nil, isFriend: false)
let guest3Profile: Profile = Profile(name: "Guest 3", imageData: nil, isFriend: false)
let guest4Profile: Profile = Profile(name: "Guest 4", imageData: nil, isFriend: false)

let exampleTeam1 = Team(list: [exampleLuis, exampleJo],name:"Team 1")
let exampleTeam2 = Team(list: [exampleSorin, exampleLeon],name:"Team 2")

// MARK: - Round 1
let exampleRound1 = Round(
    first: exampleLuis,
    second: exampleSorin,
    third: exampleLeon,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 50,
    tichuPointsTeam2: 50,

    roundPointsTeam1: 100,
    roundPointsTeam2: 0,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [exampleLuis],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

// MARK: - Round 2
let exampleRound2 = Round(
    first: exampleLeon,
    second: exampleSorin,
    third: exampleLuis,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 1,
    fourthBombs: 1,

    tichuPointsTeam1: 0,
    tichuPointsTeam2: 100,

    roundPointsTeam1: 0,
    roundPointsTeam2: 100,

    doubleWinTeam1: false,
    doubleWinTeam2: true,

    hasAnnouncedTichu: [],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

// MARK: - Round 3
let exampleRound3 = Round(
    first: exampleLuis,
    second: exampleSorin,
    third: exampleLeon,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: -25,
    tichuPointsTeam2: 125,

    roundPointsTeam1: 0,
    roundPointsTeam2: 0,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

// MARK: - Round 4
let exampleRound4 = Round(
    first: exampleJo,
    second: exampleLuis,
    third: exampleSorin,
    fourth: exampleLeon,

    firstBombs: 1,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 1,

    tichuPointsTeam1: 100,
    tichuPointsTeam2: 0,

    roundPointsTeam1: 300,
    roundPointsTeam2: -200,

    doubleWinTeam1: true,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [],
    hasAnnouncedBigTichu: [exampleJo, exampleSorin],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)
let exampleRound5 = Round(
    first: exampleLuis,
    second: exampleJo,
    third: exampleSorin,
    fourth: exampleLeon,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 100,
    tichuPointsTeam2: 0,

    roundPointsTeam1: -100,
    roundPointsTeam2: -200,

    doubleWinTeam1: true,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [],
    hasAnnouncedBigTichu: [exampleJo, exampleSorin],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

// MARK: - Round 6
let exampleRound6 = Round(
    first: exampleLeon,
    second: exampleSorin,
    third: exampleLuis,
    fourth: exampleJo,

    firstBombs: 1,
    secondBombs: 1,
    thirdBombs: 2,
    fourthBombs: 3,

    tichuPointsTeam1: 0,
    tichuPointsTeam2: 100,

    roundPointsTeam1: 0,
    roundPointsTeam2: 100,

    doubleWinTeam1: false,
    doubleWinTeam2: true,

    hasAnnouncedTichu: [],
    hasAnnouncedBigTichu: [exampleLeon,exampleSorin],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

let exampleRound7 = Round(
    first: exampleLeon,
    second: exampleSorin,
    third: exampleLuis,
    fourth: exampleJo,

    firstBombs: 3,
    secondBombs: 0,
    thirdBombs: 2,
    fourthBombs: 0,

    tichuPointsTeam1: 0,
    tichuPointsTeam2: 100,

    roundPointsTeam1: 0,
    roundPointsTeam2: 300,

    doubleWinTeam1: false,
    doubleWinTeam2: true,

    hasAnnouncedTichu: [],
    hasAnnouncedBigTichu: [exampleLeon],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

// MARK: - Game
let exampleGame = tichuGame(
    allowPingus: false,
    player1: exampleLuis,
    player2: exampleJo,
    player3: exampleSorin,
    player4: exampleLeon,
    
    

    Rounds: [
        exampleRound1,
        exampleRound2,
        exampleRound3,
        exampleRound4,
        exampleRound5,
        exampleRound6,
        exampleRound7
    ],
    target:1000,
)

// MARK: - Round 10
let exampleRound10 = Round(
    first: exampleLuis,
    second: exampleSorin,
    third: exampleLeon,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 0,
    tichuPointsTeam2: 100,

    roundPointsTeam1: 100,
    roundPointsTeam2: 0,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [exampleLuis],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

// MARK: - Round 11
let exampleRound11 = Round(
    first: exampleLuis,
    second: exampleSorin,
    third: exampleLeon,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 25,
    tichuPointsTeam2: 75,

    roundPointsTeam1: 100,
    roundPointsTeam2: 0,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [exampleLuis],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

let exampleRound12 = Round(
    first: exampleSorin,
    second: exampleJo,
    third: exampleLeon,
    fourth: exampleLuis,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 125,
    tichuPointsTeam2: -25,

    roundPointsTeam1: -200,
    roundPointsTeam2: -200,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [],
    hasAnnouncedBigTichu: [exampleLuis,exampleLeon],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)


// MARK: - Round 13
let exampleRound13 = Round(
    first: exampleLuis,
    second: exampleSorin,
    third: exampleLeon,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 0,
    tichuPointsTeam2: 100,

    roundPointsTeam1: 100,
    roundPointsTeam2: 0,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [exampleLuis],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)

// MARK: - Round 14
let exampleRound14 = Round(
    first: exampleLuis,
    second: exampleSorin,
    third: exampleLeon,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 0,
    tichuPointsTeam2: 100,

    roundPointsTeam1: 100,
    roundPointsTeam2: 0,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [exampleLuis],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)
// MARK: - Round 15
let exampleRound15 = Round(
    first: exampleLuis,
    second: exampleSorin,
    third: exampleLeon,
    fourth: exampleJo,

    firstBombs: 0,
    secondBombs: 0,
    thirdBombs: 0,
    fourthBombs: 0,

    tichuPointsTeam1: 50,
    tichuPointsTeam2: 50,

    roundPointsTeam1: 100,
    roundPointsTeam2: 0,

    doubleWinTeam1: false,
    doubleWinTeam2: false,

    hasAnnouncedTichu: [exampleLuis],
    hasAnnouncedBigTichu: [],
    hasAnnouncedPingu: [],

    team1: exampleTeam1,
    team2: exampleTeam2
)


let exampleGame2 = tichuGame(
    player1: exampleLuis,
    player2: exampleJo,
    player3: exampleSorin,
    player4: exampleLeon,
    
    

    Rounds: [
        exampleRound10,
        exampleRound11,
        exampleRound12,
        exampleRound13,
        exampleRound14,
        exampleRound15
    ],
    target:250,
)
let exampleGame3 = tichuGame(
    player1: exampleLuis,
    player2: exampleJo,
    player3: exampleSorin,
    player4: exampleLeon,
    
    

    Rounds: [
        exampleRound10,
        exampleRound11,
        exampleRound12,
        exampleRound13,
        exampleRound14,
        exampleRound15
    ],
    target:250,
)
let exampleGame4 = tichuGame(
    player1: exampleLuis,
    player2: exampleJo,
    player3: exampleSorin,
    player4: exampleLeon,
    
    

    Rounds: [
        exampleRound1,
        exampleRound2,
        exampleRound3,
        exampleRound4,
        exampleRound5,
        exampleRound6,
        exampleRound7
    ],
    target:500,
)
let exampleGame5 = tichuGame(
    player1: exampleLuis,
    player2: exampleJo,
    player3: exampleSorin,
    player4: exampleLeon,
    
    

    Rounds: [
        exampleRound1,
        exampleRound2,
        exampleRound3,
        exampleRound4,
        exampleRound5,
        exampleRound6,
        exampleRound7
    ],
    target:250,
)
let exampleGame6 = tichuGame(
    player1: exampleLuis,
    player2: exampleJo,
    player3: exampleSorin,
    player4: exampleLeon,
    
    

    Rounds: [
        exampleRound10,
        exampleRound11,
        exampleRound12,
        exampleRound13,
        exampleRound14,
        exampleRound15
    ],
    target:250,
)


var exampleHistory:[tichuGame] = []
