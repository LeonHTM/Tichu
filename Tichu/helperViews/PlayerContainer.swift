//
//  PlayerContainer.swift
//  Tichu
//
//  Created by Leon on 01.05.2026.
//

import SwiftUI

enum CanAnnounce: Equatable {
    case none
    case tichu
    case bigTichu
    case pingu
}

struct PlayerContainer: View {

    var player: Profile
    var teamIds: [Int]
    var allowPingus: Bool
    @Binding var hasAnnounced: CanAnnounce
    @Binding var bombNumber: Int
    @Environment(\.colorScheme) var colorScheme

    private var isTeam1: Bool {
        teamIds.contains(player.id)
    }

    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading) {
                Text(player.name ?? "Unknown")
                    .fontWeight(.bold)
                    .foregroundStyle(isTeam1 ? Color.accentColor : Color.primary)

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
                        Text("Big Tichu").foregroundColor(.primary)
                    }
                    .padding(10)
                    .glassEffect(hasAnnounced == .bigTichu ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                }

                HStack {
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
