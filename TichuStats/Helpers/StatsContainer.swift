//
//  StatsContainer.swift
//  Tichu
//
//  Created by Leon on 24.04.2026.
//

import SwiftUI
//MARK: - StatsContainer used in StatsView
struct StatsContainer: View {

    //MARK: Vars
    var title: String
    var description: String
    var image: String
    var counterLeft: Int
    var counterRight: Int
    var value: Double
    var percentage: Bool
    var inTop: Double
    var stat: Profile.playerStat
    var timeframe: Timeframe = .allTime
    @Environment(\.colorScheme) var colorScheme
    //MARK: Computed Vars
    var items: [Profile]
    
    //MARK: Body
    var body: some View {
        VStack(){
            HStack{
                //For certain Image insteady of loading systeImage load custom Image
                if image == "exclamationmark.2.circle" || image == "bomb" || image == "exclamationmark.3.circle" {
                    Image(image)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
                    .redactedShimmer()
                }else{
                    Image(systemName:image)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
                    .scaledToFit()
                    .redactedShimmer()
                }
                Text(title)
                    .font(.system(size:20))
                    .fontWeight(.bold)
                    .redactedShimmer()
                Spacer()
                
            }
            .padding(.leading,10)
            .padding(.top,10)
            .padding(.bottom,10)
            
            HStack{
                if percentage == false {
                    Text("\(Int(value))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .redactedShimmer()
                }else{
                    Text("\(Int(value*100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .redactedShimmer()
                }
                
            }
            Text(description)
                .font(.system(size:16))
                .multilineTextAlignment(.leading)
                .padding(.top,10)
                .padding(.horizontal,10)
                .redactedShimmer()
            if !items.isEmpty{
                Divider().padding(.horizontal, 10)
            }
            
            //Automtically Load Dictionary and display it
            VStack(alignment: .leading, spacing: 8) {
                
                //For loop over all indices, id:value itssself,index is index
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let itemValue = item.getStat(for: stat,timeframe:timeframe)
                    VStack(spacing: 0) {
                        HStack {
                            if itemValue > value {
                                HStack{
                                    Image(systemName: "chevron.up.2")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .redactedShimmer()
                                    
                                    Text(item.name ?? "")
                                        .font(.system(size: 14))
                                        .padding(.bottom, 3)
                                        .redactedShimmer()
                                }.lineLimit(.max)
                            } else if itemValue.isEqual(to: value) || itemValue == value {
                                Image(systemName: "equal")
                                    .offset(x: -1)
                                    .redactedShimmer()
                                Text(item.name ?? "")
                                    .font(.system(size: 14))
                                    .padding(.bottom, 3)
                                    .offset(x: -2)
                                    .redactedShimmer()
                            } else {
                                Image(systemName: "chevron.down.2")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .redactedShimmer()
                                Text(item.name ?? "")
                                    .font(.system(size: 14))
                                    .padding(.bottom, 3)
                                    .redactedShimmer()
                            }
                            Spacer()
                            Text(percentage ? "\(Int(itemValue*100))%" : "\(Int(itemValue))")
                                .font(.system(size: 14))
                                .redactedShimmer()
                        }
                        if index != items.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .animation(.easeInOut, value: items)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .frame(idealWidth: 164,maxWidth: 164)
        .frame(minHeight:140,alignment:.topLeading)
        .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemFill) : .white, in: .rect(cornerRadius: 24))
    }
}



//MARK: - Sortby enum 

    enum sortBy: String, CaseIterable {
        case valueUp
        case valueDown
        case nameUp
        case nameDown
    }



