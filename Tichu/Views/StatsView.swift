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
    @State private var showDebugSheetView: Bool = false
    
    // MARK: - State
    @State private var showAddPlayersSheet: Bool = false
    @State private var timeTags: [String] = ["All Time", "Year", "Month", "Week", "Today"]
    @State private var selectedTags: [String] = ["All Time"]
    @State private var sortStat: Profile.playerStat = .elo
    @State private var sortBy: sortBy.sortBy = .valueDown
    @AppStorage("statsList") private var compareList: [Int] = []
    @State private var addPlayerId: Int?
    @State private var showOfflineAlert: Bool = false
    
    // MARK: - Computed
    var filterActive: Bool { sortBy != .valueDown }

    var selectedTimeframe: Timeframe {
        withAnimation(.easeInOut){
            switch selectedTags.first {
            case "Year":  return .year
            case "Month": return .month
            case "Week":  return .week
            case "Today": return .day
            default:      return .allTime
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            
            ScrollView {
                statsGrid
                    .animation(.easeInOut, value: compareList.map { $0 })
                    .padding()
            }.scrollEdgeEffectStyle(.soft, for: .all)
            .sheet(isPresented: $showAddPlayersSheet, onDismiss: {
                withAnimation(.easeInOut) {
                    if !compareList.contains(where: { $0 == addPlayerId }) && addPlayerId != nil {
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
                    guestIndex: 2,
                    showMenu: true
                )
                .presentationDetents([.medium, .large])
            }
           
            .onChange(of: socket.connected) {
                if !socket.connected {
                    showAddPlayersSheet = false
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .refreshable {
                if socket.connected {
                    Task {
                        await network.fetchSelectedProfilesStats()
                    }
                }
            }
            .navigationTitle("Statistics")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                if network.profiles.first(where: { $0.id == userId })?.isAdmin == true{
                    ToolbarItem {
                        Button { showDebugSheetView = true } label: {
                            Image(systemName: "ant").foregroundStyle(socket.connected ? Color.green : Color.red)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationProfileImage()
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .sheet(isPresented: $showDebugSheetView) {
                DebugSheetView(
                    currentGame: Binding(
                        get: { network.games.first(where: { $0.id == network.currentGameId }) ?? Game(favorite: false,id: 0, date: Date(), target: 1000, allowPingus: true, currentPointsTeam1: 0, currentPointsTeam2: 0) },
                        set: { network.currentGameId = $0.id }
                    ),
                    showDebugSheetView: $showDebugSheetView
                )
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
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .elo, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Winner",
                description: "Percentage of Games won",
                image: "trophy",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .winnerPercentage, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.1,
                stat: .winnerPercentage,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .winnerPercentage, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Tichumaster",
                description: "Points from Tichu per Round",
                image: "number",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .tichuMaster, timeframe: selectedTimeframe) ?? 0,
                percentage: false,
                inTop: 0.75,
                stat: .tichuMaster,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .tichuMaster, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Visionary",
                description: "Tichu announced when finished first",
                image: "checkmark.circle",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .visionary, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.025,
                stat: .visionary,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .visionary, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Addict",
                description: "Games played",
                image: "pill",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .addict, timeframe: selectedTimeframe) ?? 0,
                percentage: false,
                inTop: 0.9,
                stat: .addict,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .addict, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Teamplayer",
                description: "Double Win Rate",
                image: "hands.clap",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .teamplayer, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.06,
                stat: .teamplayer,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .teamplayer, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Announcer",
                description: "Big and Small Tichus announced per Round",
                image: "megaphone",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .announcer, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.76,
                stat: .announcer,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .announcer, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Saboteur",
                description: "Tichu prevented ratio",
                image: "xmark.circle",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .saboteur, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.87,
                stat: .saboteur,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .saboteur, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Gambler",
                description: "Tichu success ratio",
                image: "exclamationmark.circle",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .gambler, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.9,
                stat: .gambler,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .gambler, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Big Gambler",
                description: "Big Tichu success ratio",
                image: "exclamationmark.2.circle",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .bigGambler, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.1,
                stat: .bigGambler,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .bigGambler, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Pingu Gambler",
                description: "Pingu success ratio",
                image: "exclamationmark.3.circle",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .pinguGambler, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.1,
                stat: .pinguGambler,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .pinguGambler, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }

            StatsContainer(
                title: "Bomber",
                description: "Bombs per Round ratio",
                image: "bomb",
                counterLeft: 1,
                counterRight: 500,
                value: network.profiles.first { $0.id == userId }?.getStat(for: .bomber, timeframe: selectedTimeframe) ?? 0,
                percentage: true,
                inTop: 0.9,
                stat: .bomber,
                timeframe: selectedTimeframe,
                items: makeItems(from: compareList, stat: .bomber, sortBy: sortBy, timeframe: selectedTimeframe)
            )
            .transition(.opacity.combined(with: .scale))
            .contextMenu { shareContextMenu }
        }
        .task {
            let profile = network.profiles.first { $0.id == userId }
            var tags: [String] = []

            tags.append("Visionary: \(profile?.getStat(for: .visionary, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Addict: \(profile?.getStat(for: .addict, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Teamplayer: \(profile?.getStat(for: .teamplayer, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Announcer: \(profile?.getStat(for: .announcer, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Saboteur: \(profile?.getStat(for: .saboteur, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Gambler: \(profile?.getStat(for: .gambler, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Big Gambler: \(profile?.getStat(for: .bigGambler, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Pingu Gambler: \(profile?.getStat(for: .pinguGambler, timeframe: selectedTimeframe) ?? 0)")
            tags.append("Bomber: \(profile?.getStat(for: .bomber, timeframe: selectedTimeframe) ?? 0)")

            let renderer = ImageRenderer(content: ShareStatsView(
                userName: profile?.name ?? "Unknown",
                userImageData: network.profileImages[userId],
                elo: profile?.elo ?? 1000.0,
                winnerPercentage: profile?.getStat(for: .winnerPercentage, timeframe: selectedTimeframe) ?? 0,
                tichuMaster: profile?.getStat(for: .tichuMaster, timeframe: selectedTimeframe) ?? 0,
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

    // MARK: - Share Context Menu
    @ViewBuilder
    private var shareContextMenu: some View {
        if let renderedImage {
            ShareLink(
                userName == "Luis" ? "Flex on Your Friends by sharing Tichu Stats with them" : "Share...",
                item: renderedImage,
                message: Text("Check my Tichu Stats out"),
                preview: SharePreview("Tichu Statistics", image: renderedImage)
            )
            .foregroundColor(.primary)
        } else {
            Button {} label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share...")
                    ProgressView()
                }
            }.disabled(true)
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
            if selection.isEmpty {
                selectedTags = ["All Time"]
            } else {
                selectedTags = selection
            }
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
