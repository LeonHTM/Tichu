//
//  StatsView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct StatsView: View {
    @State private var renderedImage: Image?
    @ObservedObject private var network = NetworkService.shared
    @StateObject private var socket = SocketService.shared
    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    @AppStorage("userName") var userName: String = "Unknown"
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - State
    @State private var showAddPlayersSheet: Bool = false
    @State private var timeTags: [String] = ["All Time", "Year", "Month", "Week", "Today"]
    @State private var selectedTags: [String] = []
    @State private var sortStat: Profile.playerStat = .elo
    @State private var sortBy: sortBy.sortBy = .valueDown
    @AppStorage("statsList") private var compareList: [Int] = []
    @State private var addPlayerId: Int?
    @State private var showOfflineAlert: Bool = false
    
    // MARK: - Computed
    var filterActive: Bool { sortBy != .valueDown }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            
            ScrollView {
                statsGrid
                    .animation(.easeInOut, value: compareList.map { $0})
                    .padding()
            }.sheet(isPresented: $showAddPlayersSheet, onDismiss: {
                withAnimation(.easeInOut) {
                    if !compareList.contains(where: { $0 == addPlayerId}) && addPlayerId != nil
                      {
                        compareList.append(addPlayerId!)
                    }
                }
            }) {
                AddPlayersSheetView(
                    showAddPlayersSheet: $showAddPlayersSheet,
                    addPlayerId: $addPlayerId,
                    alreadyAdded: compareList,
                    showGuest: .constant(false),
                    showPlayers: .constant(true),
                    showFriends: .constant(true),
                    guestIndex: 2
                )
                .presentationDetents([.medium, .large])
            }
            
            
            .onChange(of:socket.connected){
                if !socket.connected{
                    showAddPlayersSheet = false
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .refreshable {
                if socket.connected{
                    for profileId in compareList {
                        await network.fetchProfilesStats(profileId: profileId)
                    }
                }
            }
            .navigationTitle("Statistics")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationProfileImage()
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .safeAreaInset(edge: .top) { timeFilterChips }
            .safeAreaInset(edge: .bottom) { bottomBar }
        }
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 165), spacing: 15, alignment: .top)],
            spacing: 15
        ) {
            StatsContainer(
                title: "Rating",
                description: "All time Elo Rating",
                image: "chart.line.uptrend.xyaxis",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.elo ?? 1000,
                percentage: false,
                inTop: 0.025,
                stat: .elo,
                items: makeItems(from: compareList, stat: .elo, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: "Winner",
                description: ("Percentage of Games won"),
                image: ("trophy"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.winnerPercentage ?? 0),
                percentage: (true),
                inTop: 0.1,
                stat: .winnerPercentage,
                items: makeItems(from: compareList, stat: .winnerPercentage, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Tichumaster"),
                description: ("Points from Tichu per Round"),
                image: ("number"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.tichuMaster ?? 0),
                percentage: (false),
                inTop: 0.75,
                stat: .tichuMaster,
                items: makeItems(from: compareList, stat: .tichuMaster, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Visionary"),
                description: ("Tichu announced when finished first"),
                image: ("checkmark.circle"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.visionary ?? 0),
                percentage: (true),
                inTop: 0.025,
                stat: .visionary,
                items: makeItems(from: compareList, stat: .visionary, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Addict"),
                description: ("Games played"),
                image: ("pill"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.addict ?? 0),
                percentage: (false),
                inTop: 0.9,
                stat: .addict,
                items: makeItems(from: compareList, stat: .addict, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Teamplayer"),
                description: ("Double Win Rate"),
                image: ("hands.clap"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.teamplayer ?? 0),
                percentage: (true),
                inTop: 0.06,
                stat: .teamplayer,
                items: makeItems(from: compareList, stat: .teamplayer, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Announcer"),
                description: ("Big and Small Tichus announced per Round"),
                image: ("megaphone"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.announcer ?? 0),
                percentage: (true),
                inTop: 0.76,
                stat: .announcer,
                items: makeItems(from: compareList, stat: .announcer, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Saboteur"),
                description: ("Tichu prevented ratio"),
                image: ("xmark.circle"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.saboteur ?? 0),
                percentage: (true),
                inTop: 0.87,
                stat: .saboteur,
                items: makeItems(from: compareList, stat: .saboteur, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Gambler"),
                description: ("Tichu success ratio"),
                image: ("exclamationmark.circle"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.gambler ?? 0),
                percentage: (true),
                inTop: 0.9,
                stat: .gambler,
                items: makeItems(from: compareList, stat: .gambler, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Big Gambler"),
                description: ("Big Tichu success ratio"),
                image: ("exclamationmark.2.circle"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.bigGambler ?? 0),
                percentage: (true),
                inTop: 0.1,
                stat: .bigGambler,
                items: makeItems(from: compareList, stat: .bigGambler, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Pingu Gambler"),
                description: ("Pingu success ratio"),
                image: ("exclamationmark.3.circle"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.pinguGambler ?? 0),
                percentage: (true),
                inTop: 0.1,
                stat: .pinguGambler,
                items: makeItems(from: compareList, stat: .pinguGambler, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
            
            StatsContainer(
                title: ("Bomber"),
                description: ("Bombs per Round ratio"),
                image: ("bomb"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.bomber ?? 0),
                percentage: (true),
                inTop: 0.9,
                stat: .bomber,
                items: makeItems(from: compareList, stat: .bomber, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu{
                if let renderedImage {
                    ShareLink(
                        userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                        item: renderedImage,
                        message: Text("Check my Tichu Stats out"),
                        preview: SharePreview("Tichu Statistics", image: renderedImage)
                    )
                    .foregroundColor(.primary)
                }else{
                    Button{}label:{
                        HStack{
                            Image(systemName:"square.and.arrow.up")
                            Text("Share...")
                            ProgressView()
                        }
                    }.disabled(true)
                }
            }
        }.task {
            var tags: [String] = []
            
            let visionary = network.profiles.first { $0.id == userId }?.visionary ?? 0
            let addict = network.profiles.first { $0.id == userId }?.addict ?? 0
            let teamplayer = network.profiles.first { $0.id == userId }?.teamplayer ?? 0
            let announcer = network.profiles.first { $0.id == userId }?.announcer ?? 0
            let saboteur = network.profiles.first { $0.id == userId }?.saboteur ?? 0
            let gambler = network.profiles.first { $0.id == userId }?.gambler ?? 0
            let bigGambler = network.profiles.first { $0.id == userId }?.bigGambler ?? 0
            let pinguGambler = network.profiles.first { $0.id == userId }?.pinguGambler ?? 0
            let bomber = network.profiles.first { $0.id == userId }?.bomber ?? 0
            
            tags.append("Visionary: \(visionary)")
            tags.append("Addict: \(addict)")
            tags.append("Teamplayer: \(teamplayer)")
            tags.append("Announcer: \(announcer)")
            tags.append("Saboteur: \(saboteur)")
            tags.append("Gambler: \(gambler)")
            tags.append("Big Gambler: \(bigGambler)")
            tags.append("Pingu Gambler: \(pinguGambler)")
            tags.append("Bomber: \(bomber)")
            print(tags)
            let renderer = ImageRenderer(content: ShareStatsView(
                userName: network.profiles.first(where: { $0.id == userId })?.name ?? "Unknown",
                userImageData: network.profileImages[userId],
                elo: network.profiles.first { $0.id == userId }?.elo ?? 1000.0,
                winnerPercentage: network.profiles.first { $0.id == userId }?.winnerPercentage ?? 0,
                tichuMaster: network.profiles.first { $0.id == userId }?.tichuMaster ?? 0,
                accentCo: .accent,
                Tags: .constant(tags)
                
            )
            .environment(\.colorScheme, colorScheme)
            .background(colorScheme == .dark ? Color.black : Color.white))
            renderer.scale = 3
            if let image = renderer.cgImage {
                renderedImage = Image(decorative: image, scale: 1)
            }
        }
    }
    
    // MARK: - Time Filter Chips
    private var timeFilterChips: some View {
        ChipsView(tags: timeTags, onlyOne: true) { tag, isSelected in
            if !socket.connected {
                ChipView(tag: tag, isSelected: isSelected, showAlert: true)
            } else {
                ChipView(tag: tag, isSelected: isSelected, showAlert: false)
            }
        } didChangeSelection: { selection in
            selectedTags = selection
        }
        .padding(.leading, 10)
    }
    
    // MARK: - Bottom Bar
    private var bottomBar: some View {
        GlassEffectContainer {
            HStack {
                if compareList.count > 1 {
                    sortMenu
                }
                Spacer()
                compareMenu
            }
        }
    }
    
    // MARK: - Sort Menu
    private var sortMenu: some View {
        Menu {
            Button {
                sortBy = .nameDown
            } label: {
                if sortBy == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                Text("Alphabetical (A-Z)")
            }
            Button {
                sortBy = .nameUp
            } label: {
                if sortBy == .nameUp { Image(systemName: "checkmark") } else { Image("ABC.up") }
                Text("Alphabetical (Z-A)")
            }
            Divider()
            Button {
                sortBy = .valueDown
            } label: {
                if sortBy == .valueDown { Image(systemName: "checkmark") } else { Image("123.down") }
                Text("By Value (High-Low)")
            }
            Button {
                sortBy = .valueUp
            } label: {
                if sortBy == .valueUp { Image(systemName: "checkmark") } else { Image("123.up") }
                Text("By Value (Low-High)")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 22))
                .foregroundColor(filterActive ? Color.accent : Color.primary)
        }
        .labelStyle(.titleAndIcon)
        .menuOrder(.fixed)
        .padding(10)
        .glassEffect(.regular.interactive(), in: Circle())
        .padding(.leading, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Compare Menu
    private var compareMenu: some View {
        if socket.connected {
            return AnyView(
                Menu {
                    Button {
                        showAddPlayersSheet = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                        Text("Add Player to compare")
                    }
                    if !compareList.isEmpty {
                        Divider()
                    }
                    ForEach(compareList, id: \.self) { item in
                        Button {
                            withAnimation(.easeInOut) {
                                compareList.removeAll { $0 == item }
                            }
                        } label: {
                            Image("person.badge.remove")
                            Text("Remove \(network.profiles.first { $0.id == item }?.name ?? "Unknown")")
                        }
                    }
                    if compareList.count > 1 {
                        Divider()
                        Button {
                            compareList = []
                        } label: {
                            Image(systemName: "minus.circle")
                            Text("Remove All Players")
                        }
                    }
                } label: {
                    Image("person.badge.edit")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                    Text("Edit comparison")
                        .foregroundColor(.primary)
                }
                .labelStyle(.titleAndIcon)
                .menuOrder(.fixed)
                .padding(10)
                .glassEffect(.regular.interactive())
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            )
        } else {
            return AnyView(
                Button(action: {
                    showOfflineAlert = true
                }) {
                    HStack {
                        Image("person.badge.edit")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                        Text("Edit comparison")
                            .foregroundColor(.primary)
                    }
                }
                .alert(isPresented: $showOfflineAlert) {
                    offlineView.offlineAlert()
                }
                .padding(10)
                .glassEffect(.regular.interactive())
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            )
        }
    }
}

#Preview {
    StatsView()
}
