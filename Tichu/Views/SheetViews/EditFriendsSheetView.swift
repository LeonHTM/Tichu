//
//  EditFriendsSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI
import TipKit

struct EditFriendsSheetView: View {

    // MARK: - Bindings
    @Binding var showFriendsSheet: Bool

    // MARK: - Storage
    @AppStorage("userName") var userName: String = ""
    @ObservedObject private var network = NetworkService.shared

    // MARK: - State
    @State private var friendsFilterActive: Bool = false
    @State private var sortByFriends: sortBy.sortBy = .nameDown
    @State private var sortByRequests: sortBy.sortBy = .nameDown
    @State private var friendsListCopy: [Friend] = []
    @State private var requestedFriendsListCopy: [Profile] = []
    @State private var originalFriends: [Friend] = []
    @State private var originalRequests: [Profile] = []
    @State private var showAddPlayerSheet: Bool = false
    @State private var currentProfile: Profile?

    // MARK: - Computed
    var sortedFriendsList: [Friend] {
        makeItems(from: friendsListCopy, stat: .dateAdded, sortBy: sortByFriends)
    }

    var sortedRequestsList: [Profile] {
        makeItems(from: requestedFriendsListCopy, stat: .dateAdded, sortBy: sortByRequests)
    }

    // MARK: - Done Button
    private var doneButton: some View {
        Button("Done", systemImage: "checkmark") {
            Task {
                // Friends removed = in original but not in copy
                let removedIds = originalFriends
                    .filter { orig in !friendsListCopy.contains(where: { $0.id == orig.id }) }
                    .map { $0.id }

                // Requests accepted = in original requests but now in friends
                let acceptedIds = originalRequests
                    .filter { req in friendsListCopy.contains(where: { $0.id == req.id }) }
                    .map { $0.id }

                // Requests rejected = in original requests but not in copy anymore
                let rejectedIds = originalRequests
                    .filter { req in !requestedFriendsListCopy.contains(where: { $0.id == req.id }) && !friendsListCopy.contains(where: { $0.id == req.id }) }
                    .map { $0.id }

                for id in removedIds {
                    await network.removeFriend(profileId: 3, friendId: id)
                }
                for id in acceptedIds {
                    if let req = network.friendRequests.first(where: { $0.senderId == id }) {
                        await network.respondToFriendRequest(requestId: req.id, action: "accepted")
                    }
                }
                for id in rejectedIds {
                    if let req = network.friendRequests.first(where: { $0.senderId == id }) {
                        await network.respondToFriendRequest(requestId: req.id, action: "rejected")
                    }
                }
                await network.fetchFriends(profileId: 3)

                showFriendsSheet = false
            }
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    if requestedFriendsListCopy.count > 0 {
                        friendRequestsHeader
                        friendRequestsRows
                        footerNote
                    }else{
                        Text("You have no friends yet. Request somebody!").listRowBackground(Color.clear).foregroundStyle(.secondary)
                    }
                    friendsHeader
                    friendsRows
                    
                }
                .onAppear {
                    friendsListCopy = network.friends
                    requestedFriendsListCopy = network.friendRequestProfiles
                    originalFriends = network.friends
                    originalRequests = network.friendRequestProfiles
                }
                .onChange(of: network.friends) {
                    withAnimation(.easeInOut) {
                        friendsListCopy = network.friends
                        originalFriends = network.friends
                    }
                }
                .listSectionSpacing(0)
                .navigationTitle("Manage Friendlist")
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .bottom) { addFriendButton }
                .sheet(isPresented: $showAddPlayerSheet, onDismiss: {
                    if let profile = currentProfile {
                        withAnimation(.easeInOut) {
                            let newFriend = Friend(id: profile.id, profile: profile, friendsSince: Date())
                            friendsListCopy.append(newFriend)
                        }
                    }
                }) {
                    AddPlayersSheetView(
                        showAddPlayersSheet: $showAddPlayerSheet,
                        addPlayer: $currentProfile,
                        alreadyAdded: friendsListCopy.map { $0.profile },
                        showGuest: false,
                        showPlayers: true,
                        showFriends: false,
                        guestIndex: 0
                    )
                    .presentationDetents([.medium, .large])
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        doneButton
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            showFriendsSheet = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Friend Requests Header
    private var friendRequestsHeader: some View {
        Section {
            HStack {
                Text("Friend Requests").fontWeight(.bold)
                Spacer()
                if requestedFriendsListCopy.count > 1 {
                    Menu {
                        Button {
                            withAnimation(.easeInOut) {
                                sortByRequests = .nameDown
                                friendsFilterActive = false
                            }
                        } label: {
                            if sortByRequests == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                            Text("Alphabetical (A-Z)")
                        }
                        Button {
                            withAnimation(.easeInOut) {
                                sortByRequests = .nameUp
                                friendsFilterActive = true
                            }
                        } label: {
                            if sortByRequests == .nameDown { Image("ABC.up") } else { Image(systemName: "checkmark") }
                            Text("Alphabetical (Z-A)")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                }
            }
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Friend Requests Rows
    private var friendRequestsRows: some View {
        Section {
            ForEach(sortedRequestsList, id: \.id) { profile in
                HStack {
                    ProfileImage(data: network.friendRequestImages[profile.id], size: 44)
                    VStack(alignment: .leading) {
                        Text(profile.name ?? "Unknown")
                    }
                    Spacer()
                    GlassEffectContainer {
                        HStack {
                            Button {
                                withAnimation(.easeInOut) {
                                    requestedFriendsListCopy.removeAll { $0.id == profile.id }
                                }
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .foregroundStyle(Color.primary)
                            .padding(13)
                            .glassEffect(.regular.interactive(), in: Circle())

                            Button {
                                withAnimation(.easeInOut) {
                                    requestedFriendsListCopy.removeAll { $0.id == profile.id }
                                    let newFriend = Friend(id: profile.id, profile: profile, friendsSince: Date())
                                    friendsListCopy.append(newFriend)
                                }
                            } label: {
                                Image(systemName: "checkmark")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .foregroundStyle(Color.white)
                            .padding(13)
                            .glassEffect(.regular.tint(.accentColor).interactive(), in: Circle())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Friends Header
    private var friendsHeader: some View {
        Section {
            if friendsListCopy.count > 0 {
                HStack {
                    Text("Friends").fontWeight(.bold)
                    Spacer()
                    if friendsListCopy.count > 1 {
                        Menu {
                            Button {
                                withAnimation(.easeInOut) {
                                    sortByFriends = .nameDown
                                    friendsFilterActive = false
                                }
                            } label: {
                                if sortByFriends == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                                Text("Alphabetical (A-Z)")
                            }
                            Button {
                                withAnimation(.easeInOut) {
                                    sortByFriends = .nameUp
                                    friendsFilterActive = true
                                }
                            } label: {
                                if sortByFriends == .nameUp { Image(systemName: "checkmark") } else { Image("ABC.up") }
                                Text("Alphabetical (Z-A)")
                            }
                            Divider()
                            Button {
                                withAnimation(.easeInOut) {
                                    sortByFriends = .valueDown
                                    friendsFilterActive = true
                                }
                            } label: {
                                if sortByFriends == .valueDown { Image(systemName: "checkmark") } else { Image("Date.down") }
                                Text("Date Added (New - Old)")
                            }
                            Button {
                                withAnimation(.easeInOut) {
                                    sortByFriends = .valueUp
                                    friendsFilterActive = true
                                }
                            } label: {
                                if sortByFriends == .valueUp { Image(systemName: "checkmark") } else { Image("Date.up") }
                                Text("Date Added (Old - New)")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 20))
                        }
                        .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Friends Rows
    private var friendsRows: some View {
        Section {
            ForEach(sortedFriendsList) { friend in
                HStack {
                    ProfileImage(data: network.profileImages[friend.id], size: 44)
                    VStack(alignment: .leading) {
                        Text(friend.profile.name ?? "Unknown")
                        if let date = friend.friendsSince {
                            Text("Friends since \(formattedDate(date))")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 16))
                        } else {
                            Text("Unknown")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            friendsListCopy.removeAll { $0.id == friend.id }
                        }
                    } label: {
                        Image(systemName: "person.badge.minus")
                        Text("Remove Friend")
                    }
                    .tint(.red)
                }
            }
            TipView(ListSwipeFriendTip()).tipBackground(Color.clear)
        }
        .task {
            do {
                try Tips.resetDatastore()
                try Tips.configure()
            } catch {
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Footer Note
    private var footerNote: some View {
        Section {
            Text("Friends can be added to a Tichu round without having to ask them first.")
                .foregroundStyle(Color.secondary)
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Add Friend Button
    private var addFriendButton: some View {
        HStack {
            Spacer()
            Button {
                showAddPlayerSheet = true
            } label: {
                Image(systemName: "plus")
                Text("Request Friend")
            }
            .foregroundStyle(Color.primary)
            .padding(13)
            .glassEffect(.regular.interactive())
        }
        .padding(.horizontal)
    }
}

#Preview {
    EditFriendsSheetView(
        showFriendsSheet: .constant(true)
    )
}
