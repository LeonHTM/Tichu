//
//  playerContainer.swift
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

struct playerContainer: View {
    var player: Profile
    @Binding var hasAnnounced: CanAnnounce
    @Binding var bombNumber: Int
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        GlassEffectContainer{
            VStack(alignment:.leading){
                Text(player.name ?? "Unknown").fontWeight(.bold)
                HStack{
                    Button{
                        DispatchQueue.main.async {
                            if hasAnnounced == .tichu {
                                hasAnnounced = .none
                            }else{
                                hasAnnounced = .tichu
                            }
                        }
                        
                    }label:{
                        Text("Tichu").foregroundColor(.primary)
                    }.padding(10).glassEffect(hasAnnounced == .tichu ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                    Button{
                        if hasAnnounced == .bigTichu {
                            hasAnnounced = .none
                        } else {
                            hasAnnounced = .bigTichu
                        }
                    }label:{
                        //Deutsch : Gr. Tichu
                        Text("Big Tichu").foregroundColor(.primary)
                    }.padding(10).glassEffect(hasAnnounced == .bigTichu ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                }
                HStack{
                    Button{
                        if hasAnnounced == .pingu {
                            hasAnnounced = .none
                        } else {
                            hasAnnounced = .pingu
                        }
                    }label:{
                        Text("Pingu").foregroundColor(.primary)
                    }.padding(10).glassEffect(hasAnnounced == .pingu ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                    Button{
                        if bombNumber < 3{
                            bombNumber+=1
                    
                        }else{
                            bombNumber = 0
                        }
                    }label:{
                        Text("Bombs: \(bombNumber)").foregroundColor(.primary)
                    }.padding(10).glassEffect(bombNumber > 0 ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                }
            }.padding(10)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var hasAnnounced: CanAnnounce = .none
        @State var bombNumber: Int = 0
        var body: some View {
            playerContainer(player: exampleSorin,hasAnnounced: $hasAnnounced, bombNumber: $bombNumber)
        }
    }
    return PreviewWrapper()
}
