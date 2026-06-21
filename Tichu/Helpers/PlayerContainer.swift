//
//  PlayerContainer.swift
//  Tichu
//
//  Created by Leon on 01.05.2026.
//

import SwiftUI

//MARK: - Possible Cases of Announcements
enum CanAnnounce: Equatable {
    case none
    case tichu
    case bigTichu
    case pingu
}

//MARK: - PlayerContainer used in AddRounds and AddRoundsLocal
struct PlayerContainer: View {
    //MARK: Variables
    var player: Profile
    var teamIds: [Int]
    var allowPingus: Bool
    var isTeam1: Bool
    @Binding var hasAnnounced: CanAnnounce
    @Binding var bombNumber: Int
    @Environment(\.colorScheme) var colorScheme
    //MARK: Body
    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading) {
                //Title
                HStack{
                    Text(player.name ?? "Unknown")
                        .fontWeight(.bold)
                        .foregroundStyle(isTeam1 ? Color.accentColor : Color.primary)
                    Spacer()
                }
                //Row of Tichu and Big Tichu
                HStack {
                    Button {
                        DispatchQueue.main.async {
                            hasAnnounced = hasAnnounced == .tichu ? .none : .tichu
                        }
                    } label: {
                        Text("Tichu").foregroundColor(.primary)
                    }
                    
                    .padding(10)
                    .glassEffect(hasAnnounced == .tichu ? .regular.tint(.accentColor).interactive() : .regular.interactive())

                    Button {
                        hasAnnounced = hasAnnounced == .bigTichu ? .none : .bigTichu
                    } label: {
      
                        ViewThatFits {
                                                    Text("Big Tichu").foregroundColor(.primary)
                                                    Text("B. Tichu").foregroundColor(.primary)
                                                }
           
                    }
                    .padding(10)
                    .glassEffect(hasAnnounced == .bigTichu ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                }
                //Row of Bombs and Pingus, only shown when allowPingus
                HStack {
                    if allowPingus{
                        Button {
                            hasAnnounced = hasAnnounced == .pingu ? .none : .pingu
                        } label: {
                            Text("Pingu").foregroundColor(.primary)
                        }
                        .padding(10)
                        .glassEffect(
                            hasAnnounced == .pingu
                            ? .regular.tint(.accentColor).interactive()
                            : !allowPingus
                            ? .regular.tint(.secondary).interactive()
                            : .regular.interactive()
                        )
                        .disabled(!allowPingus)
                    }
                    Button {
                        bombNumber = bombNumber < 3 ? bombNumber + 1 : 0
                    } label: {
                        
                        Text("Bombs: \(bombNumber)").foregroundColor(.primary)
                       
                    }
                    .padding(10)
                    .glassEffect(bombNumber > 0 ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                }
                
            }
            .padding(10)
        }
    }
}


#Preview {
    PlayerContainer(
        player: Profile(),
        teamIds: [12,13],
        allowPingus: true,
        isTeam1: true,
        hasAnnounced: .constant(.tichu),
        bombNumber: .constant(1)
    )
    .environment(\.colorScheme, .light)
}
