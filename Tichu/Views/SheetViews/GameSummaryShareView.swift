//
//  GameSummaryShareView.swift
//  Tichu
//
//  Created by Leon on 02.05.2026.
//

import SwiftUI


struct GameSummaryShareView: View {
    @Environment(\.colorScheme) var colorScheme
    let currentGame: tichuGame
    let accentCo :Color
    
    func gameWinner() -> String {
        if currentGame.currentPointsTeam1 >= currentGame.target ||
            currentGame.currentPointsTeam2 >= currentGame.target {
            
            if currentGame.currentPointsTeam1 > currentGame.currentPointsTeam2 {
                return "Team 1"
            } else if currentGame.currentPointsTeam2 > currentGame.currentPointsTeam1 {
                return "Team 2"
            }
        }
        
        return "Unknown"
    }

    private func teamPlacement(team: Team, currentRound: Round) -> some View{
        let p0 = team.list[0]
        let p1 = team.list[1]
        
        var p0_place: String = ""
        var p1_place: String = ""
        
        if currentRound.first == p0{
            p0_place = "1"
        }else if currentRound.second == p0{
            p0_place = "2"
        }else if currentRound.third == p0{
            p0_place = "3"
        }else{
            p0_place = "4"
        }
        
        
        if currentRound.first == p1{
            p1_place = "1"
        }else if currentRound.second == p1{
            p1_place = "2"
        }else if currentRound.third == p1{
            p1_place = "3"
        }else{
            p1_place = "4"
        }
        
        return Text("(\(p0_place)/\(p1_place))").monospaced()
    }
    private func teamAnnounced(team: Team, round: Round,lead:String) -> some View {
        
        let p0 = team.list[0]
        let p1 = team.list[1]

        let (text0, color0, symbol0,bomb0): (String, Color, String,Int) = {
            
            if round.hasAnnouncedBigTichu.contains(p0) {
                return ("T", p0 == round.first ? .green : .red, p0 == round.first ? "checkmark" : "xmark",p0 == round.first ? round.firstBombs : p0 == round.second ? round.secondBombs : p0 == round.third ? round.thirdBombs : p0 == round.fourth ? round.fourthBombs : 99)
                
            }  else if round.hasAnnouncedTichu.contains(p0) {
                return ("t", p0 == round.first ? .green : .red, p0 == round.first ? "checkmark" : "xmark",p0 == round.first ? round.firstBombs : p0 == round.second ? round.secondBombs : p0 == round.third ? round.thirdBombs : p0 == round.fourth ? round.fourthBombs : 99)
                
            }  else if round.hasAnnouncedPingu.contains(p0) {
                return ("P", p0 == round.first ? .green : .red, p0 == round.first ? "checkmark" : "xmark",p0 == round.first ? round.firstBombs : p0 == round.second ? round.secondBombs : p0 == round.third ? round.thirdBombs : p0 == round.fourth ? round.fourthBombs : 99)
                
            }
            return ("C", .clear, "",p0 == round.first ? round.firstBombs : p0 == round.second ? round.secondBombs : p0 == round.third ? round.thirdBombs : p0 == round.fourth ? round.fourthBombs : 99)
        }()
        let (text1, color1, symbol1,bomb1): (String, Color, String,Int) = {
            
            if round.hasAnnouncedBigTichu.contains(p1) {
                return ("T", p1 == round.first ? .green : .red, p1 == round.first ? "checkmark" : "xmark",p1 == round.first ? round.firstBombs : p1 == round.second ? round.secondBombs : p1 == round.third ? round.thirdBombs : p1 == round.fourth ? round.fourthBombs : 99)
                
            }else if round.hasAnnouncedPingu.contains(p1) {
                return ("P", p1 == round.first ? .green : .red, p1 == round.first ? "checkmark" : "xmark",p1 == round.first ? round.firstBombs : p1 == round.second ? round.secondBombs : p1 == round.third ? round.thirdBombs : p1 == round.fourth ? round.fourthBombs : 99)
            }else if round.hasAnnouncedTichu.contains(p1) {
                return ("t", p1 == round.first ? .green : .red, p1 == round.first ? "checkmark" : "xmark",p1 == round.first ? round.firstBombs : p1 == round.second ? round.secondBombs : p1 == round.third ? round.thirdBombs : p1 == round.fourth ? round.fourthBombs : 99)
            }
            return ("C", .clear, "",p1 == round.first ? round.firstBombs : p1 == round.second ? round.secondBombs : p1 == round.third ? round.thirdBombs : p1 == round.fourth ? round.fourthBombs : 99)

        }()

        return HStack {
            if text0 != "C"{
                HStack{
                    if lead == "leading"{
                        Text("\(p0.name?.prefix(2) ?? "Uk")").foregroundStyle(color0).lineLimit(1)
                        Text("\(bomb0)")
                        Text(text0).foregroundStyle(color0).lineLimit(1)
                    }else if lead == "trailing"{
                        Text(text0).foregroundStyle(color0).lineLimit(1)
                        Text("\(p0.name?.prefix(2) ?? "Uk")").foregroundStyle(color0).lineLimit(1)
                        Text("\(bomb0)")
                        
                    }
                }.font(.system(size:17)).frame(width:60,alignment: lead == "trailing" ? .trailing : .leading)
                
            }else{
                HStack{
                    Text("\(p0.name?.prefix(2) ?? "Uk")").lineLimit(1)
                    Text("\(bomb0)")
                }.font(.system(size:17)).frame(width:60,alignment: lead == "trailing" ? .trailing : .leading).monospaced()
            }
    
            if text1 != "C"{
                HStack{
                    if lead == "leading"{
                        Text("\(p1.name?.prefix(2) ?? "Uk")").foregroundStyle(color1).lineLimit(1)
                        Text("\(bomb1)")
                        Text(text1).foregroundStyle(color1).lineLimit(1)
                    }else if lead == "trailing"{
                        Text(text1).foregroundStyle(color1).lineLimit(1)
                        Text("\(p1.name?.prefix(2) ?? "Uk")").foregroundStyle(color1).lineLimit(1)
                        Text("\(bomb1)")
                        
                    }
                }.font(.system(size:17)).frame(width:60,alignment: lead == "trailing" ? .trailing : .leading).monospaced()
                
            }else{
                HStack{
                    Text("\(p1.name?.prefix(2) ?? "Uk")").lineLimit(1)
                    Text("\(bomb1)")
                }.font(.system(size:17)).frame(width:60,alignment: lead == "trailing" ? .trailing : .leading)
            }
        }
        
        .opacity(colorScheme == .dark ? 0.66 : 1)
    }



    var body: some View {
        
        VStack(spacing: 24) {
            
            Text("Round Results")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            
            
            HStack{
                VStack{
                    Text("Team 1:").fontWeight(.bold)
                    Text("\(currentGame.team1?.list[0].name ?? "Unknnown")").font(.title).fontWeight(.bold)
                    Text("\(currentGame.team1?.list[1].name ?? "Unknown")").font(.title).fontWeight(.bold)
                }.foregroundStyle(accentCo)
                Spacer()
                VStack{
                    Text("Team 2:").fontWeight(.bold)
                    Text("\(currentGame.team2?.list[0].name ?? "Unknnown")").font(.title).fontWeight(.bold)
                    Text("\(currentGame.team2?.list[1].name ?? "Unknown")").font(.title).fontWeight(.bold)
                }
                
            }.padding(.horizontal,30)
            
            GameOverViewChartView(
                currentGame: .constant(currentGame)
            )
            .frame(height: 250)
            HStack {
                
                VStack {
                    
                    Text("Team 1")
                        .font(.headline)
                        .foregroundStyle(accentCo)
                    
                    Text("\(currentGame.currentPointsTeam1)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(accentCo)
                }
                
                Spacer()
                VStack{
                    Text("Target: \(currentGame.target)").fontWeight(.bold)
                    Text("Winner: \(gameWinner())").fontWeight(.bold).foregroundStyle(gameWinner() == "Team 1" ? accentCo : Color.primary)
                }
                Spacer()
                
                VStack {
                    
                    Text("Team 2")
                        .font(.headline)
                    
                    Text("\(currentGame.currentPointsTeam2)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }.padding(.horizontal,30)
            
            Text("Details").fontWeight(.bold).font(.title)
            HStack{
                Text("Team 1").padding(.trailing,23).foregroundStyle(accentCo)
                Text("Rounds:").fontWeight(.bold)
                Text("Team 2").padding(.leading,20)
            }
            HStack(alignment:.top){
                VStack{
                    ForEach(currentGame.Rounds, id: \.id) { currentRound in
                        
                        HStack {
                            
                            teamPlacement(team:currentGame.team1!,currentRound:currentRound).frame(width: 60, alignment: .trailing).padding(.trailing,60)
                           
                            
                            teamAnnounced(
                                team: currentGame.team1!,
                                round: currentRound,
                                lead: "trailing"
                            ).frame(width: 65, alignment: .trailing)
                            
                            
                            Text("\(currentRound.tichuPointsTeam1)")
                                .fontWeight(.bold)
                            
                                .frame(width: 50, alignment: .trailing).monospaced()
                        }
                    }
                    
                }
                
                VStack{
                    ForEach(currentGame.Rounds, id: \.id) { currentRound in
                        
                        HStack {
                            Text("\(currentRound.tichuPointsTeam2)")
                                .fontWeight(.bold)
                                .frame(width: 50, alignment: .leading).monospaced()
                            
                            
                            
                            teamAnnounced(
                                team: currentGame.team2!,
                                round: currentRound,
                                lead: "leading"
                            ).frame(width: 65, alignment: .leading)
                            
                            teamPlacement(team:currentGame.team2!,currentRound:currentRound).frame(width: 60, alignment: .leading).padding(.leading,60)
                            
                            
                        }
                    }
                    
                }
                
            }
            HStack{
                Text("Made with Tichu App").fontWeight(.bold)
                Image("AppLogo").resizable().frame(width:45,height:45)
            }
            
            
        }.frame(width: 500).background(colorScheme == .dark ? Color.black : Color.white)
    }
    
        
       
    }

    


#Preview {
    GameSummaryShareView(currentGame:exampleGame,accentCo:.accent)
}
