//
//  AdPlayersSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI

struct AddPlayersSheetView: View {

    // MARK: - Bindings
    @Binding var showAddPlayersSheet: Bool
    @Binding var addPlayer: Profile?
    var alreadyAdded: [Profile]
    @Binding var showGuest: Bool
    @Binding var showPlayers: Bool
    @Binding var showFriends: Bool
    var guestIndex: Int
    @AppStorage("userId") var userId: Int = -69420
    @StateObject private var socket = SocketService.shared

    // MARK: - State
    @ObservedObject private var network = NetworkService.shared
    
    @State private var searchText: String = ""
    @State private var sortByFriends: sortBy.sortBy = .nameDown
    @State private var sortByPlayers: sortBy.sortBy = .nameDown

    // MARK: - Computed
    var friendsFilterActive: Bool { sortByFriends != .nameDown }
    var playersFilterActive: Bool { sortByPlayers != .nameDown }

    var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var sortedFriends: [Friend] {
        makeItems(
            from: network.friends.filter {
                guard !query.isEmpty else { return true }
                return ($0.profile.name ?? "").range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            },
            stat: .elo,
            sortBy: sortByFriends
        )
    }

    var sortedPlayers: [Profile] {
        makeItems(
            from: network.profiles.filter {
                guard $0.id != userId else { return false }
                guard !query.isEmpty else { return true }
                return ($0.name ?? "").range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            },
            stat: .elo,
            sortBy: sortByPlayers
        )
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    if showGuest { guestRow }
                } else if sortedFriends.isEmpty && sortedPlayers.isEmpty {
                    noResultsRow
                }

                if showFriends {
                    if !sortedFriends.isEmpty { friendsHeader }
                    friendsRows
                }

                if showPlayers {
                    if !sortedPlayers.isEmpty { playersHeader }
                    playersRows
                }
            }
            .padding(.top, showGuest ? 0 : -45)
            .listSectionSpacing(0)
            .animation(.easeInOut, value: searchText)
            .navigationTitle(
                showPlayers && showFriends ? "Add Players" :
                !showFriends ? "Request Friend" : "Edit Friends"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        showAddPlayersSheet = false
                    }
                }
            }
            
        }
        .searchable(text: $searchText)
    }

    // MARK: - Guest Row
    private var guestRow: some View {
        Section {
            HStack {
                ProfileImage(data: nil, size: 44)
                Button("Guest") {
                    if guestIndex == 2 {
                        addPlayer = guest2Profile
                    } else if guestIndex == 3 {
                        addPlayer = guest3Profile
                    } else {
                        addPlayer = guest4Profile
                    }
                    showAddPlayersSheet = false
                }
                .foregroundColor(.primary)
                Spacer()
            }
        }
    }

    // MARK: - No Results Row
    private var noResultsRow: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Could not find '\(query)'")
            }
            Spacer()
        }
    }

    // MARK: - Friends Header
    private var friendsHeader: some View {
        Section {
            HStack {
                Text("Friends").fontWeight(.bold)
                Spacer()
                if sortedFriends.count != 1 {
                    sortMenu(active: friendsFilterActive, binding: $sortByFriends, showDateOptions: false)
                }
            }
            .padding(.top, 20)
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Friends Rows
    private var friendsRows: some View {
        Section {
            ForEach(sortedFriends) { friend in
                playerButton(profile: friend.profile)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Players Header
    private var playersHeader: some View {
        Section {
            HStack {
                Text("All Players").fontWeight(.bold)
                Spacer()
                if sortedPlayers.count != 1 {
                    sortMenu(active: playersFilterActive, binding: $sortByPlayers, showDateOptions: false)
                }
            }
            .padding(.top, 20)
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Players Rows
    private var playersRows: some View {
        ForEach(sortedPlayers) { profile in
            playerButton(profile: profile)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Player Button
    private func playerButton(profile: Profile) -> some View {
        let isAdded = alreadyAdded.contains(where: { $0.id == profile.id })
        return Button {
            
            //Also load Stats in Case of StatsView
            if showGuest == false{
                Task {
                    await network.fetchProfilesStats(profileId: profile.id)
                    if let updated = network.profiles.first(where: { $0.id == profile.id }) {
                                        addPlayer = updated
                                    }
                }
            }else{
                addPlayer = profile
            }
            if var player = addPlayer {
                player.imageData = network.profileImages[player.id]
                addPlayer = player
            }
            showAddPlayersSheet = false
            
        } label: {
            HStack {
                ProfileImage(data: network.profileImages[profile.id], size: 44)
                Text(profile.name ?? "Unknown")
                Spacer()
                if let elo = profile.elo {
                    Text("\(elo)").foregroundStyle(.secondary).font(.system(size: 16))
                }
            }
        }
        .disabled(isAdded)
        .foregroundColor(isAdded ? .secondary : .primary)
    }

    // MARK: - Sort Menu
    private func sortMenu(active: Bool, binding: Binding<sortBy.sortBy>, showDateOptions: Bool) -> some View {
        Menu {
            Button {
                withAnimation(.easeInOut) { binding.wrappedValue = .nameDown }
            } label: {
                if binding.wrappedValue == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                Text("Alphabetical (A-Z)")
            }
            Button {
                withAnimation(.easeInOut) { binding.wrappedValue = .nameUp }
            } label: {
                if binding.wrappedValue == .nameUp { Image(systemName: "checkmark") } else { Image("ABC.up") }
                Text("Alphabetical (Z-A)")
            }
            Divider()
            Button {
                withAnimation(.easeInOut) { binding.wrappedValue = .valueDown }
            } label: {
                if binding.wrappedValue == .valueDown { Image(systemName: "checkmark") } else { Image("123.down") }
                Text("By Value (High-Low)")
            }
            Button {
                withAnimation(.easeInOut) { binding.wrappedValue = .valueUp }
            } label: {
                if binding.wrappedValue == .valueUp { Image(systemName: "checkmark") } else { Image("123.up") }
                Text("By Value (Low-High)")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 20))
        }
        .foregroundColor(active ? .accentColor : .primary)
    }
}

/*#Preview {
    AddPlayersSheetView(
        showAddPlayersSheet: .constant(true),
        addPlayer: .constant(exampleProfiles[0]),
        alreadyAdded: [],
        showGuest: .constant(true),
        showPlayers: .constant(true),
        showFriends: .constant(true),
        guestIndex: 2
    )
}*/
