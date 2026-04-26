//
//  profileLogic.swift
//  Tichu
//
//  Created by Leon on 25.04.2026.
//

import SwiftUI

struct profile: Identifiable {
    let id = UUID()
    var name: String?
    var imageData: Data?
    var isFriend: Bool
    //Statistics
    var elo: Int?
    var winnerPercentage: Int?
    var tichuMaster: Double?
    var visionary: Int?
    var addict: Int?
    var teamplayer: Int?
    var announcer: Int?
    var saboteur: Int?
    var gambler: Int?
    var bigGambler: Int?
    var bomber: Int?
    
    //type playerStat
    enum playerStat {
        case elo
        case winnerPercentage
        case tichuMaster
        case visionary
        case addict
        case teamplayer
        case announcer
        case saboteur
        case gambler
        case bigGambler
        case bomber
    }
    
    
    //return value of Struct
    func getStat(for stat: playerStat) -> Double {
        switch stat {
        case .elo:
            if let elo {
                return Double(elo)
            }
            
        case .winnerPercentage:
            if let winnerPercentage {
                return Double(winnerPercentage)
            }
            
        case .tichuMaster:
            if let tichuMaster {
                return tichuMaster
            }
            
        case .visionary:
            if let visionary {
                return Double(visionary)
            }
            
        case .addict:
            if let addict {
                return Double(addict)
            }
            
        case .teamplayer:
            if let teamplayer {
                return Double(teamplayer)
            }
            
        case .announcer:
            if let announcer {
                return Double(announcer)
            }
            
        case .saboteur:
            if let saboteur {
                return Double(saboteur)
            }
            
        case .gambler:
            if let gambler {
                return Double(gambler)
            }
            
        case .bigGambler:
            if let bigGambler {
                return Double(bigGambler)
            }
            
        case .bomber:
            if let bomber {
                return Double(bomber)
            }
        }
        
        return 0
    }
}
    
    
// Function to create sorted profile list for given DataSet, Stat and sortBy
func makeItems(
    from compareList: [profile],
    stat: profile.playerStat,
    sortBy: sortBy.sortBy
) -> [profile] {
    
    switch sortBy {
        
    case .valueUp:
        return compareList.sorted {
            $0.getStat(for: stat) < $1.getStat(for: stat)
        }
        
    case .valueDown:
        return compareList.sorted {
            $0.getStat(for: stat) > $1.getStat(for: stat)
        }
        
    case .nameUp:
        return compareList.sorted {
            ($0.name ?? "").lowercased() > ($1.name ?? "").lowercased()
        }
        
    case .nameDown:
        return compareList.sorted {
            ($0.name ?? "").lowercased() < ($1.name ?? "").lowercased()
        }
    }
}

