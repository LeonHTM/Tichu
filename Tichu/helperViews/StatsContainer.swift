//
//  StatsContainer.swift
//  Tichu
//
//  Created by Leon on 24.04.2026.
//

import SwiftUI
//StatsContainer -> The class of Conatiners used in StatsView
struct StatsContainer: View {
    //Bindings
    var title: String
    var description: String
    var image: String
    var counterLeft: Int
    var counterRight: Int
    var value: Double
    var percentage: Bool
    var inTop: Double
    var stat: Profile.playerStat
    @Environment(\.colorScheme) var colorScheme
    //Computed Vars
    var items: [Profile]
    
    
    var body: some View {
        
        VStack(){
            HStack{
                if image == "exclamationmark.2.circle" || image == "bomb" || image == "exclamationmark.3.circle" {
                    Image(image
                    )
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
                }else{
                    Image(systemName:image
                    )
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
                    .scaledToFit()
                }
                
                Text(title)
                    .font(.system(size:20))
                    .fontWeight(.bold)
                Spacer()
                
            }
            .padding(.leading,10)
            .padding(.top,10)
            .padding(.bottom,10)
            
            HStack{
                if percentage == false{
                    Text("\(Int(value))").font(.title3).fontWeight(.bold)
                }else{
                    Text("\(Int(value))%").font(.title3).fontWeight(.bold)
                }
                
            }
            Text(description).font(.system(size:16)).multilineTextAlignment(.leading).padding(.top,10).padding(.horizontal,10)
            if !items.isEmpty{
                Divider().padding(.horizontal, 10)
            }
            
            //Automtically Load Dictionary and display it
            VStack(alignment: .leading, spacing: 8) {
                
                //For loop over all indices, id:value itssself,index is index
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let itemValue = item.getStat(for: stat)

                    VStack(spacing: 0) {
                        HStack {
                            if Int(itemValue) > Int(value) {
                                HStack{
                                    Image(systemName: "chevron.up.2")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                    
                                    Text(item.name ?? "")
                                        //.fontWeight(.semibold)
                                        .font(.system(size: 14))
                                        .padding(.bottom, 3)
                                }.lineLimit(.max)
                                
                                    

                            } else if Int(itemValue) == Int(value) {
                                Image(systemName: "equal")
                                    .offset(x: -1)

                                Text(item.name ?? "")
                                    //.fontWeight(.semibold)
                                    .font(.system(size: 14))
                                    .padding(.bottom, 3)
                                    .offset(x: -2)

                            } else {
                                Image(systemName: "chevron.down.2")
                                    .resizable()
                                    .frame(width: 12, height: 12)

                                Text(item.name ?? "")
                                    //.fontWeight(.semibold)
                                    .font(.system(size: 14))
                                    .padding(.bottom, 3)
                                    
                            }

                            Spacer()

                            Text(percentage ? "\(Int(itemValue))%" : "\(Int(itemValue))")
                                .font(.system(size: 14))
                        }

                        if index != items.count - 1 {
                            Divider()
                        }
                    }
                }
            }.animation(.easeInOut, value: items)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .frame(idealWidth: 165,maxWidth: 165)
        .frame(minHeight:140,alignment:.topLeading)
            .overlay{
                /*
                if inTop <= 0.05 {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 1)
                }else if inTop <= 0.075{
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.silver, lineWidth: 1)
                }else if inTop <= 0.1{
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.bronce, lineWidth: 1)
                }*/
                }
            .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
            //.glassEffect(.regular.tint(.gray.opacity(0.2)).interactive(),in:.rect(cornerRadius:24))
            
    }
}



//Sortby enum inside its own class
struct sortBy{
    enum sortBy {
        case valueUp
        case valueDown
        case nameUp
        case nameDown
    }
}






/*#Preview {
    StatsContainer(
        title: .constant("Rating"),
        description: .constant("All Time Elo Rating"),
        image: .constant("exclamationmark.2.circle"),
        counterLeft: .constant(1),
        counterRight: .constant(5000),
        value: .constant(1000),
        percentage: .constant(false),
        compareList: .constant(["Jo":1000,"Luis":570,"Sorin":5000]),
        sortBy:.constant("alphabeticalUp")
    )
}*/
