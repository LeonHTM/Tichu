//
//  statsContainerView.swift
//  Tichu
//
//  Created by Leon on 24.04.2026.
//

import SwiftUI
//StatsContainerView -> The class of Conatiners used in StatsView
struct statsContainerView: View {
    //Bindings
    @Binding var title: String
    @Binding var description: String
    @Binding var image: String
    @Binding var counterLeft: Int
    @Binding var counterRight: Int
    @Binding var value: Double
    @Binding var percentage: Bool
    //Computed Vars
    var items: [(key: String, value: Double)]
    
    var body: some View {
        
        VStack(){
            HStack{
                if image == "exclamationmark.2.circle" || image == "bomb"{
                    Image(image
                    )
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.accent)
                }else{
                    Image(systemName:image
                    )
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.accent)
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
                /*Text("\(counterLeft)/\(counterRight)").font(.footnote).foregroundStyle(.gray.opacity(0.75))*/
            }
            Text(description).padding(.horizontal,10)
            if !items.isEmpty{
                Divider().padding(.horizontal, 10)
            }
            
            //Automtically Load Dictionary and display it
            VStack(alignment: .leading, spacing: 8) {
                
                //For loop over all indices, id:value itssself,index is index
                ForEach(Array(items.enumerated()), id: \.element.key) { index, item in
                    VStack(spacing: 0) {
                        HStack {
                            if Int(item.value) > Int(value) {
                                Image(systemName: "chevron.up.2")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                Text(item.key)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 14))
                                    .padding(.bottom,3)
                            } else if Int(item.value) == Int(value) {
                                Image(systemName: "equal")
                                    .offset(x: -1)
                                Text(item.key)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 14))
                                    .padding(.bottom,3)
                                    .offset(x:-2)
                            } else {
                                Image(systemName: "chevron.down.2")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                Text(item.key)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 14))
                                    .padding(.bottom,3)
                            }

                            

                            Spacer()

                            Text(percentage ? "\(Int(item.value))%" : "\(Int(item.value))")
                                .font(.system(size: 14))
                        }

                        if index != items.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
            .frame(width: 165)
            .frame(minHeight:150,alignment:.topLeading)
            .glassEffect(.regular.tint(.gray.opacity(0.2)).interactive(),in:.rect(cornerRadius:20))
    }
}

//PlayerStats Struct with playerstat var and value function
struct playerStats {
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
    //Vars of Struct
    var elo: Int
    var winnerPercentage: Int
    var tichuMaster: Double
    var visionary: Int
    var addict: Int
    var teamplayer: Int
    var announcer: Int
    var saboteur: Int
    var gambler: Int
    var bigGambler: Int
    var bomber: Int
    
    //return value of Struct
    func value(for stat: playerStat) -> Double {
        switch stat {
        case .elo: return Double(elo)
        case .winnerPercentage: return Double(winnerPercentage)
        case .tichuMaster: return tichuMaster
        case .visionary: return Double(visionary)
        case .addict: return Double(addict)
        case .teamplayer: return Double(teamplayer)
        case .announcer: return Double(announcer)
        case .saboteur: return Double(saboteur)
        case .gambler: return Double(gambler)
        case .bigGambler: return Double(bigGambler)
        case .bomber: return Double(bomber)
        }
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

//Function to create item dictionary for given DataSet, Stat and sortBy
func makeItems(
    from compareList: [String: playerStats],
    stat: playerStats.playerStat,
    sortBy: sortBy.sortBy
) -> [(key: String, value: Double)] {

    let mapped = compareList.map {
        (key: $0.key, value: $0.value.value(for: stat))
    }

    switch sortBy {

    case .valueUp:
        return mapped.sorted { $0.value < $1.value }

    case .valueDown:
        return mapped.sorted { $0.value > $1.value }

    case .nameUp:
        return mapped.sorted { $0.key.lowercased() > $1.key.lowercased() }

    case .nameDown:
        return mapped.sorted { $0.key.lowercased() < $1.key.lowercased() }
    }
}



/*#Preview {
    statsContainerView(
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
