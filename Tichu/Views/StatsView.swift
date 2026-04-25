//
//  StatsView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct StatsView: View {
    //Storage
    @AppStorage("userImageData") private var userImageData: Data?
    @AppStorage("userElo") var userElo: Double = 1000
    @AppStorage("userWinner") var userWinner: Double = 0
    @AppStorage("userTichuMaster") var userTichuMaster: Double = 0
    @AppStorage("userVisionary") var userVisionary: Double = 0
    @AppStorage("userAddict") var userAddict: Double = 0
    @AppStorage("userTeamplayer") var userTeamplayer: Double = 0
    @AppStorage("userAnnouncer") var userAnnouncer: Double = 0
    @AppStorage("userSaboteur") var userSaboteur: Double = 0
    @AppStorage("userGambler") var userGambler: Double = 0
    @AppStorage("userBigGambler") var userBigGambler: Double = 0
    @AppStorage("userBomber") var userBomber: Double = 0
    
    //Vars
    @State private var showAddPlayersSheet: Bool = false
    @State private var selectedImage: UIImage?
    @State private var timeTags: [String] = ["All Time","Year","Month","Week","Today"]
    @State private var selectedTags: [String] = []
    @State private var sortStat: playerStats.playerStat = .elo
    @State private var sortBy: sortBy.sortBy = .nameDown
    
    //Computed Vars
    var filterActive: Bool {sortBy != .nameDown}

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 165),spacing: 15, alignment:.top)
                    ],
                    
                    spacing: 15
                ) {

                    statsContainerView(
                        title: .constant("Rating"),
                        description: .constant("All time Elo Rating"),
                        image: .constant("chart.line.uptrend.xyaxis"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userElo,
                        percentage: .constant(false),
                        items: makeItems(from: exampleStatsDic, stat: .elo, sortBy: sortBy)
                        
                    )

                    statsContainerView(
                        title: .constant("Winner"),
                        description: .constant("Percentage of Games won"),
                        image: .constant("trophy"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userWinner,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .winnerPercentage, sortBy: sortBy)
                    )
                    statsContainerView(
                        title: .constant("Tichumaster"),
                        description: .constant("Points from Tichu per Round"),
                        image: .constant("number"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userTichuMaster,
                        percentage: .constant(false),
                        items:makeItems(from: exampleStatsDic, stat: .tichuMaster, sortBy: sortBy)
                    )
                    statsContainerView(
                        title: .constant("Visionary"),
                        description: .constant("Tichu announced when finished first"),
                        image: .constant("checkmark.circle"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userVisionary,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .visionary, sortBy: sortBy)
                    )

                    statsContainerView(
                        title: .constant("Addict"),
                        description: .constant("Games played"),
                        image: .constant("pill"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userAddict,
                        percentage: .constant(false),
                        items:makeItems(from: exampleStatsDic, stat: .addict, sortBy: sortBy)
                    )
                    statsContainerView(
                        title: .constant("Teamplayer"),
                        description: .constant("Double Win Rate"),
                        image: .constant("hands.clap"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userTeamplayer,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .teamplayer, sortBy: sortBy)
                    )
                    statsContainerView(
                        title: .constant("Announcer"),
                        description: .constant("Big and Small Tichus announced per round"),
                        image: .constant("megaphone"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userAnnouncer,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .announcer, sortBy: sortBy)
                    )
                    statsContainerView(
                        title: .constant("Saboteur"),
                        description: .constant("Tichu prevented ratio"),
                        image: .constant("xmark.circle"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userSaboteur,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .saboteur, sortBy: sortBy)
                    )
                    statsContainerView(
                        title: .constant("Gambler"),
                        description: .constant("Tichu success ratio"),
                        image: .constant("exclamationmark.circle"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userGambler,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .gambler, sortBy: sortBy)
                    )
                    statsContainerView(
                        title: .constant("Big Gambler"),
                        description: .constant("Big Tichu success ratio"),
                        image: .constant("exclamationmark.2.circle"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userBigGambler,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .bigGambler, sortBy: sortBy)
                    )
                    
                    statsContainerView(
                        title: .constant("Bomber"),
                        description: .constant("Bombs per round ratio"),
                        image: .constant("flame"),
                        counterLeft: .constant(1),
                        counterRight: .constant(500),
                        value: $userBomber,
                        percentage: .constant(true),
                        items:makeItems(from: exampleStatsDic, stat: .bomber, sortBy: sortBy)
                    )
                }
                .padding()
            }
            
            .navigationTitle("Statistics")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    profileImage(selectedImage: selectedImage, size: 44)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .safeAreaInset(edge: .top) {
                ChipsView(tags: timeTags) { tag, isSelected in
                    ChipView(tag, isSelected: isSelected)
                }didChangeSelection: { selection in
                    selectedTags = selection
                }
                .padding(.leading, 10)
               
            }
            .safeAreaInset(edge: .bottom) {
                GlassEffectContainer{
                    HStack{
                        Menu {
                            Button() {
                                DispatchQueue.main.async {
                                    sortBy = .nameDown
                                }
                            }label:{
                                if sortBy == .nameDown{
                                    Image(systemName:"checkmark")
                                }else{
                                    Image("ABC.down")
                                }
                                Text("Alphabetical (A-Z)")
                                
                            }
                            Button() {
                                DispatchQueue.main.async {
                                    sortBy = .nameUp
                                }
                            }label:{
                                if sortBy == .nameUp{
                                    Image(systemName:"checkmark")
                                }else{
                                    Image("ABC.up")
                                }
                                
                                Text("Alphabetical (Z-A)")
                            }
                            Divider()
                            
                            Button() {
                                DispatchQueue.main.async {
                                    sortBy = .valueDown
                                }
                            }label:{
                                if sortBy == .valueDown{
                                    Image(systemName:"checkmark")
                                }else{
                                    Image("123.down")
                                }
                                Text("By Value (High-Low)")
                                
                            }
                            
                            Button() {
                                DispatchQueue.main.async {
                                    sortBy = .valueUp
                                }
                            }label:{
                                if sortBy == .valueUp{
                                    Image(systemName:"checkmark")
                                }else{
                                    Image("123.up")
                                }
                                Text("By Value (Low-High)")
                                
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22)).foregroundColor(filterActive == true ? Color.accent : Color.primary)
                        }.labelStyle(.titleAndIcon).menuOrder(.fixed).padding(10).glassEffect(.regular.interactive()).padding(.leading,20).padding(.bottom,10)
                        Spacer()
                        Menu{
                            Button(){
                                DispatchQueue.main.async {
                                    showAddPlayersSheet = true
                                }
                            }label:{
                                Image(systemName:"person.badge.plus")
                                Text("Add player to compare")
                            }
                            if !makeItems(from: exampleStatsDic, stat: .winnerPercentage, sortBy: .nameDown).isEmpty{
                                Divider()
                            }
                            ForEach(makeItems(from: exampleStatsDic, stat: .winnerPercentage, sortBy: .nameDown), id: \.0) { item in
                                Button {
                                    DispatchQueue.main.async {
                                        // action
                                    }
                                } label: {
                                    Image("person.badge.remove")
                                    Text("Remove \(item.0)")
                                }
                            }
                        } label: {
                            Image("person.badge.edit")
                                .font(.system(size: 20)).foregroundColor( Color.primary)
                            Text("Edit comparison").foregroundColor(Color.primary)
                        }.labelStyle(.titleAndIcon).menuOrder(.fixed).padding(10).glassEffect(.regular.interactive()).padding(.trailing,20).padding(.bottom,10).sheet(isPresented: $showAddPlayersSheet) {
                            AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet,addPlayer:.constant(exampleProfile),alreadyAdded: [],showGuest:false).presentationDetents([.medium,.large])
                            
                        }
                         //alternatively .buttonStyle(.glass)
                    }
                }
               
            }
        }.refreshable {
            
        }.onAppear {
            selectedImage = dataToPhoto(data:userImageData)
        }
        
    }
}

#Preview {
    StatsView()
}
