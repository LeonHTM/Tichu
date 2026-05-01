//
//  playerContainer.swift
//  Tichu
//
//  Created by Leon on 01.05.2026.
//

import SwiftUI

struct playerContainer: View {
    @Binding var hasAnnounced: canAnnounce
    @Binding var bombNumber: Int
    
    
    var body: some View {
        GlassEffectContainer{
            VStack(alignment:.leading){
                Text("Sorin").fontWeight(.bold)
                HStack{
                    Button{
                        hasAnnounced = tichu
                    }label:{
                        Text("Tichu").foregroundColor(.primary)
                    }.padding(10).glassEffect(hasAnnouncedTichu ? .regular.tint(.accentColor).interactive() : .regular.interactive())
                    Button{
                        
                    }label:{
                        //Deutsch : Gr. Tichu
                        Text("Big Tichu").foregroundColor(.primary)
                    }.padding(10).glassEffect(.regular.interactive())
                }
                HStack{
                    Button{
                        
                    }label:{
                        Text("Pingu").foregroundColor(.primary)
                    }.padding(10).glassEffect(.regular.interactive())
                    Button{
                        
                    }label:{
                        Text("Bombs: 0").foregroundColor(.primary)
                    }.padding(10).glassEffect(.regular.interactive())
                }
            }.padding(10).background(.gray.opacity(0.175), in: .rect(cornerRadius: 24))
        }
    }
}

#Preview {
    playerContainer(hasAnnounced: .constant(.canAnnounce.tichu),bombNumber: .constant(0))
}
