//
//  EditFriendsSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI
import TipKit

struct EditFriendsSheetView: View {
    @Namespace private var FriendsSpace

    // MARK: - Bindings
    @Binding var showFriendsSheet: Bool

    // MARK: - Storage
    @AppStorage("userName") var userName: String = ""
    @ObservedObject private var network = NetworkService.shared
    @StateObject private var socket = SocketService.shared
    @AppStorage("userId") private var userId: Int = -69420

    // MARK: - State
    @State private var friendsFilterActive: Bool = false

    @State private var sortByFriends: sortBy = .nameDown
    @State private var sortByRequests: sortBy = .nameDown
    @State private var sortBySentRequests: sortBy = .nameDown

    @State private var friendList: [Friend] = []
    @State private var friendsListCopy: [Friend] = []

    @State private var requestedFriendsList: [Int] = []
    @State private var requestedFriendsListCopy: [Int] = []

    @State private var sentRequestsList: [Int] = []
    @State private var sentRequestsListCopy: [Int] = []

    @State private var isSending: Bool = false
    @State private var showAddPlayerSheet: Bool = false
    @State private var currentProfileId: Int?

    // MARK: - Computed

    var sortedFriendsList: [Friend] {
        makeItems(from: friendsListCopy, stat: .dateAdded, sortBy: sortByFriends)
    }

    var sortedRequestsList: [Profile] {
        let profiles = requestedFriendsListCopy.compactMap { id in
            network.profiles.first { $0.id == id }
        }
        return makeItems(from: profiles, stat: .dateAdded, sortBy: sortByRequests)
    }

    var sortedSentRequestsList: [Profile] {
        let profiles = sentRequestsListCopy.compactMap { id in
            network.profiles.first { $0.id == id }
        }
        return makeItems(from: profiles, stat: .dateAdded, sortBy: sortBySentRequests)
    }

    // MARK: - Done Button
    private var doneButton: some View {
        Button("Done", systemImage: "checkmark") {
            Task {
                isSending = true

                // MARK: - COMPUTE CHANGES
                let removedFriendIds = friendList
                    .filter { orig in !friendsListCopy.contains(where: { $0.id == orig.id }) }
                    .map { $0.id }

                let acceptedIds = requestedFriendsList
                    .filter { id in friendsListCopy.contains(where: { $0.id == id }) }

                let rejectedIds = requestedFriendsList
                    .filter { id in
                        !friendsListCopy.contains(where: { $0.id == id }) &&
                        !requestedFriendsListCopy.contains(id)
                    }

                let cancelledSentIds = sentRequestsList
                    .filter { !sentRequestsListCopy.contains($0) }

                let newSentRequestIds = sentRequestsListCopy
                    .filter { !sentRequestsList.contains($0) }

                // MARK: - SEND ALL IN PARALLEL
                await withTaskGroup(of: Void.self) { group in
                    for id in removedFriendIds {
                        group.addTask { await network.removeFriend(profileId: userId, friendId: id) }
                    }
                    for senderId in acceptedIds {
                        group.addTask { await network.respondToFriendRequest(receiverId: userId, senderId: senderId, action: "accepted") }
                    }
                    for senderId in rejectedIds {
                        group.addTask { await network.respondToFriendRequest(receiverId: userId, senderId: senderId, action: "rejected") }
                    }
                    for receiverId in cancelledSentIds {
                        group.addTask { await network.respondToFriendRequest(receiverId: receiverId, senderId: userId, action: "rejected") }
                    }
                    for receiverId in newSentRequestIds {
                        group.addTask { await network.sendFriendRequest(senderId: userId, receiverId: receiverId) }
                    }
                }

                // MARK: - REMOVE ONLY HANDLED NOTIFICATIONS
                let handledIds = (acceptedIds + rejectedIds).map { "friend-request-\($0)" }
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: handledIds)

                // MARK: - REFRESH IN PARALLEL
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { await network.fetchFriends(profileId: userId) }
                    group.addTask { await network.fetchFriendRequests(profileId: userId) }
                    group.addTask { await network.fetchSentRequests(profileId: userId) }
                }

                // Badge = remaining pending requests after refresh
                try? await UNUserNotificationCenter.current().setBadgeCount(network.friendRequests.count)

                showFriendsSheet = false
                isSending = false
                
            }
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if isSending {
                        ProgressView()
                    }
                    else{
                        List {
                            if requestedFriendsListCopy.count > 0 {
                                friendRequestsHeader
                                friendRequestsRows
                            }
                            friendsHeader
                            friendsRows
                            
                            if sentRequestsListCopy.count > 0 {
                                sentRequestsHeader
                                sentRequestsRows
                            }
                        }    .safeAreaInset(edge: .bottom) { addFriendButton }
                    }
                }
                .animation(.easeInOut, value: isSending)
                .task {
                    await network.fetchFriends(profileId: userId)
                    await network.fetchFriendRequests(profileId: userId)
                }
                .onChange(of: network.isOnline) {
                    if !network.isOnline { showFriendsSheet = false }
                }
                .onAppear {
                    withAnimation(.easeInOut) {
                        friendList = network.friends
                        friendsListCopy = network.friends

                        sentRequestsList = network.sentRequests.map { $0.receiverId }
                        sentRequestsListCopy = network.sentRequests.map { $0.receiverId }

                        requestedFriendsList = network.friendRequests.map { $0.senderId }
                        requestedFriendsListCopy = network.friendRequests.map { $0.senderId }
                    }
                }
                .onChange(of: network.friends) {
                    withAnimation(.easeInOut) {
                        friendsListCopy = network.friends
                        friendList = network.friends
                    }
                }
                .onChange(of: network.sentRequests.map { $0.receiverId }) {
                    withAnimation(.easeInOut) {
                        sentRequestsListCopy = network.sentRequests.map { $0.receiverId }
                        sentRequestsList = network.sentRequests.map { $0.receiverId }
                    }
                }
                .onChange(of: network.friendRequests.map { $0.id }) {
                    withAnimation(.easeInOut) {
                        requestedFriendsList = network.friendRequests.map { $0.senderId }
                        requestedFriendsListCopy = network.friendRequests.map { $0.senderId }
                    }
                }
                .listSectionSpacing(0)
                .navigationTitle("Manage Friendlist")
                .navigationBarTitleDisplayMode(.inline)
            
                .sheet(isPresented: $showAddPlayerSheet, onDismiss: {
                    if let profileId = currentProfileId {
                        if sentRequestsList.contains(profileId) {
                            if !sentRequestsListCopy.contains(profileId) {
                                withAnimation(.easeInOut) {
                                    sentRequestsListCopy.append(profileId)
                                }
                            }
                        } else if friendsListCopy.contains(where: { $0.id == profileId }) {
                            // mutual request auto-accepted, already a friend
                        } else {
                            withAnimation(.easeInOut) {
                                sentRequestsListCopy.append(profileId)
                            }
                        }
                    }
                }) {
                    AddPlayersSheetView(
                        showAddPlayersSheet: $showAddPlayerSheet,
                        addPlayerId: $currentProfileId,
                        alreadyAdded: friendsListCopy.map { $0.id } + sentRequestsListCopy,
                        showGuest: .constant(false),
                        showPlayers: .constant(true),
                        showFriends: .constant(false),
                        guestIndex: 0,
                        showMenu: true
                    )
                    .presentationDetents([.medium, .large]).navigationTransition(.zoom(sourceID:"69420",in:FriendsSpace))
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { doneButton }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") { showFriendsSheet = false }
                    }
                }
            }
            .task {
                await network.fetchSentRequests(profileId: userId)
            }
        }
    }

    // MARK: - Friend Requests Header
    private var friendRequestsHeader: some View {
        Section {
            HStack {
                Text("Recieved Requests").fontWeight(.bold)
                Spacer()
                if requestedFriendsListCopy.count > 1 {
                    Menu {
                        Button {
                            withAnimation(.easeInOut) { sortByRequests = .nameDown; friendsFilterActive = false }
                        } label: {
                            if sortByRequests == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                            Text("Alphabetical (A-Z)")
                        }
                        Button {
                            withAnimation(.easeInOut) { sortByRequests = .nameUp; friendsFilterActive = true }
                        } label: {
                            if sortByRequests == .nameUp { Image(systemName: "checkmark") } else { Image("ABC.up") }
                            Text("Alphabetical (Z-A)")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 20))
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
                                    requestedFriendsListCopy.removeAll { $0 == profile.id }
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
                                    requestedFriendsListCopy.removeAll { $0 == profile.id }
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
                                withAnimation(.easeInOut) { sortByFriends = .nameDown; friendsFilterActive = false }
                            } label: {
                                if sortByFriends == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                                Text("Alphabetical (A-Z)")
                            }
                            Button {
                                withAnimation(.easeInOut) { sortByFriends = .nameUp; friendsFilterActive = true }
                            } label: {
                                if sortByFriends == .nameUp { Image(systemName: "checkmark") } else { Image("ABC.up") }
                                Text("Alphabetical (Z-A)")
                            }
                            Divider()
                            Button {
                                withAnimation(.easeInOut) { sortByFriends = .valueDown; friendsFilterActive = true }
                            } label: {
                                if sortByFriends == .valueDown { Image(systemName: "checkmark") } else { Image("date.down") }
                                Text("Date Added (New - Old)")
                            }
                            Button {
                                withAnimation(.easeInOut) { sortByFriends = .valueUp; friendsFilterActive = true }
                            } label: {
                                if sortByFriends == .valueUp { Image(systemName: "checkmark") } else { Image("date.up") }
                                Text("Date Added (Old - New)")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 20))
                        }
                        .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                    }
                }
            } else {
                if sentRequestsListCopy.count == 0 && requestedFriendsListCopy.count == 0 {
                    Text("You have no friends yet. Request somebody!")
                        .listRowBackground(Color.clear)
                        .foregroundStyle(.secondary)
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
                            Text("Friends since \(date.formatted(date: .complete, time: .omitted))")
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
                    Button(role: .destructive) {
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
            if friendsListCopy.count > 0 {
                TipView(ListSwipeFriendTip()).tipBackground(Color.clear)
            }
        }
        .task {
            do { try Tips.configure() } catch {
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Sent Requests Header
    private var sentRequestsHeader: some View {
        Section {
            HStack {
                Text("Sent Requests").fontWeight(.bold)
                Spacer()
                if sentRequestsListCopy.count > 1 {
                    Menu {
                        Button {
                            withAnimation(.easeInOut) { sortBySentRequests = .nameDown; friendsFilterActive = false }
                        } label: {
                            if sortBySentRequests == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                            Text("Alphabetical (A-Z)")
                        }
                        Button {
                            withAnimation(.easeInOut) { sortBySentRequests = .nameUp; friendsFilterActive = true }
                        } label: {
                            if sortBySentRequests == .nameUp { Image(systemName: "checkmark") } else { Image("ABC.up") }
                            Text("Alphabetical (Z-A)")
                        }
                        Divider()
                        Button {
                            withAnimation(.easeInOut) { sortBySentRequests = .valueDown; friendsFilterActive = true }
                        } label: {
                            if sortBySentRequests == .valueDown { Image(systemName: "checkmark") } else { Image("date.down") }
                            Text("Date Added (New - Old)")
                        }
                        Button {
                            withAnimation(.easeInOut) { sortBySentRequests = .valueUp; friendsFilterActive = true }
                        } label: {
                            if sortBySentRequests == .valueUp { Image(systemName: "checkmark") } else { Image("date.up") }
                            Text("Date Added (Old - New)")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 20))
                    }
                    .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                }
            }
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Sent Requests Rows
    private var sentRequestsRows: some View {
        Section {
            ForEach(sortedSentRequestsList) { request in
                HStack {
                    ProfileImage(data: network.profileImages[request.id], size: 44)
                    VStack(alignment: .leading) {
                        Text(request.name ?? "Unknown")
                        Text("Requested")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation(.easeInOut) {
                            sentRequestsListCopy.removeAll { $0 == request.id }
                        }
                    } label: {
                        Image(systemName: "person.badge.minus")
                        Text("Remove Request")
                    }
                }
            }
        }
        .task {
            do { try Tips.configure() } catch {
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
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
            }.matchedTransitionSource(id: "69420", in: FriendsSpace)
            .foregroundStyle(Color.primary)
            .padding(13)
            .glassEffect(.regular.interactive())
        }
        .padding(.horizontal)
    }
}

#Preview {
    EditFriendsSheetView(showFriendsSheet: .constant(true))
}
