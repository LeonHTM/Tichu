//
//  StatsView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct StatsView: View {

    @ObservedObject private var network = NetworkService.shared
    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    
    // MARK: - State
    @State private var showAddPlayersSheet: Bool = false
    @State private var timeTags: [String] = ["All Time", "Year", "Month", "Week", "Today"]
    @State private var selectedTags: [String] = []
    @State private var sortStat: Profile.playerStat = .elo
    @State private var sortBy: sortBy.sortBy = .valueDown
    @State private var compareList: [Profile] = []
    @State private var addPlayer: Profile? = nil

    // MARK: - Computed
    var filterActive: Bool { sortBy != .valueDown }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                statsGrid
                    .animation(.easeInOut, value: compareList.map { $0.id })
                    .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .refreshable { }
            .navigationTitle("Statistics")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ProfileImage(data: network.profileImages[userId], size: 44)
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
                value: Double(network.profiles.first { $0.id == userId }?.elo ?? 1000),
                percentage: false,
                inTop: 0.025,
                stat: .elo,
                items: makeItems(from: compareList, stat: .elo, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))

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

            StatsContainer(
                title: ("Bomber"),
                description: ("Bombs per Round ratio"),
                image: ("flame"),
                counterLeft: (1),
                counterRight: (500),
                value: Double(network.profiles.first { $0.id == userId }?.bomber ?? 0),
                percentage: (true),
                inTop: 0.9,
                stat: .bomber,
                items: makeItems(from: compareList, stat: .bomber, sortBy: sortBy)
            )
            .transition(.opacity.combined(with: .scale))
        }.task {
            await network.fetchProfilesStats(profileId: userId)
        }
    }

    // MARK: - Time Filter Chips
    private var timeFilterChips: some View {
        ChipsView(tags: timeTags) { tag, isSelected in
            ChipView(tag, isSelected: isSelected)
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
        .glassEffect(.regular.interactive(),in:Circle())
        .padding(.leading, 20)
        .padding(.bottom, 10)
    }

    // MARK: - Compare Menu
    private var compareMenu: some View {
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
            ForEach(compareList, id: \.id) { item in
                Button {
                    withAnimation(.easeInOut) {
                        compareList.removeAll { $0.id == item.id }
                    }
                } label: {
                    Image("person.badge.remove")
                    Text("Remove \(item.name ?? "Unknown")")
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
        .sheet(isPresented: $showAddPlayersSheet, onDismiss: {
            withAnimation(.easeInOut) {
                if !compareList.contains(where: { $0.id == addPlayer?.id ?? Profile().id }),
                   addPlayer?.name ?? Profile().name != nil {
                    compareList.append(addPlayer ?? Profile())
                }
            }
        }) {
            AddPlayersSheetView(
                showAddPlayersSheet: $showAddPlayersSheet,
                addPlayer: $addPlayer,
                alreadyAdded: compareList,
                showGuest: false,
                showPlayers: true,
                showFriends: true,
                guestIndex: 2
            )
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    StatsView()
}
