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
    @StateObject private var socket = SocketService.shared
    @AppStorage("userId") private var userId: Int = -69420

    // MARK: - State
    @State private var friendsFilterActive: Bool = false
    
    @State private var sortByFriends: sortBy.sortBy = .nameDown
    @State private var sortByRequests: sortBy.sortBy = .nameDown
    @State private var sortBySentRequests: sortBy.sortBy = .nameDown
    
    @State private var friendList: [Friend] = []
    @State private var friendsListCopy: [Friend] = []
    
    @State private var requestedFriendsList: [Profile] = []
    @State private var requestedFriendsListCopy: [Profile] = []
    
    @State private var sentRequestsListCopy: [Profile] = []
    @State private var sentRequestsList : [Profile] = []
    
    
    @State private var showAddPlayerSheet: Bool = false
    
    @State private var currentProfile: Profile?

    // MARK: - Computed
    var sortedFriendsList: [Friend] {
        makeItems(from: friendsListCopy, stat: .dateAdded, sortBy: sortByFriends)
    }

    var sortedRequestsList: [Profile] {
        makeItems(from: requestedFriendsListCopy, stat: .dateAdded, sortBy: sortByRequests)
    }
    
    
    var sortedSentRequestsList: [Profile] {
        
        return makeItems(from: sentRequestsListCopy, stat: .dateAdded, sortBy: sortBySentRequests)
    }
    
    
    
    // MARK: - Done Button
    private var doneButton: some View {
        Button("Done", systemImage: "checkmark") {
            Task {

                // MARK: - FRIENDS REMOVED
                let removedFriendIds = friendList
                    .filter { orig in !friendsListCopy.contains(where: { $0.id == orig.id }) }
                    .map { $0.id }

                for id in removedFriendIds {
                    await network.removeFriend(profileId: userId, friendId: id)
                }

                // MARK: - RECEIVED REQUESTS ACCEPTED
                let acceptedIds = requestedFriendsList
                    .filter { req in friendsListCopy.contains(where: { $0.id == req.id }) }
                    .map { $0.id }

                for senderId in acceptedIds {
                    await network.respondToFriendRequest(
                        receiverId: userId,
                        senderId: senderId,
                        action: "accepted"
                    )
                }

                // MARK: - RECEIVED REQUESTS REJECTED
                let rejectedIds = requestedFriendsList
                    .filter { req in
                        !friendsListCopy.contains(where: { $0.id == req.id }) &&
                        !requestedFriendsListCopy.contains(where: { $0.id == req.id })
                    }
                    .map { $0.id }

                for senderId in rejectedIds {
                    await network.respondToFriendRequest(
                        receiverId: userId,
                        senderId: senderId,
                        action: "rejected"
                    )
                }

                // MARK: - SENT REQUESTS CANCELLED
                let cancelledSentIds = sentRequestsList
                    .filter { sent in
                        !sentRequestsListCopy.contains(where: { $0.id == sent.id })
                    }
                    .map { $0.id }

                for receiverId in cancelledSentIds {
                    await network.respondToFriendRequest(
                        receiverId: receiverId,
                        senderId: userId,
                        action: "rejected"   // cancel = reject on server
                    )
                }
                let newSentRequestIds = sentRequestsListCopy
                    .filter { new in
                        !sentRequestsList.contains(where: { $0.id == new.id })
                    }
                    .map { $0.id }

                for receiverId in newSentRequestIds {
                    await network.sendFriendRequest(
                        senderId: userId,
                        receiverId: receiverId
                    )
                }

                showFriendsSheet = false
                
                // MARK: - REFRESH
                await network.fetchFriends(profileId: userId)
                await network.fetchFriendRequests(profileId: userId)
                await network.fetchSentRequests(profileId: userId)

                
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
                       
                    }
                    friendsHeader
                    friendsRows
                    
                    if sentRequestsListCopy.count > 0 {
                        sentRequestsHeader
                        sentRequestsRows
                        
                    }
                }
                .task {
                    await network.fetchProfiles()
                    await network.fetchFriends(profileId: userId)
                    await network.fetchFriendRequests(profileId: userId)
                }
                .onChange(of:socket.connected){
                    if !socket.connected{
                        showFriendsSheet = false
                    }
                }
                
                .onAppear {
                    withAnimation(.easeInOut) {
                        friendList = network.friends
                        friendsListCopy = network.friends
                        
                        let receiverIds = network.sentRequests.map { $0.receiverId }
                        sentRequestsList = network.profiles.filter { receiverIds.contains($0.id)}
                        sentRequestsListCopy =  network.profiles.filter { receiverIds.contains($0.id)}
                        
                        requestedFriendsList = network.friendRequestProfiles
                        requestedFriendsListCopy = network.friendRequestProfiles
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
                        let receiverIds = network.sentRequests.map { $0.receiverId }
                        sentRequestsListCopy = network.profiles.filter { receiverIds.contains($0.id) }
                        sentRequestsList = network.profiles.filter { receiverIds.contains($0.id) }
                    }
                }
                .onChange(of: network.friendRequests.map { $0.id }){
                    withAnimation(.easeInOut) {
                        requestedFriendsList = network.friendRequestProfiles
                        requestedFriendsListCopy = network.friendRequestProfiles
                    }
                }
                
                .listSectionSpacing(0)
                .navigationTitle("Manage Friendlist")
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .bottom) { addFriendButton }
                .sheet(isPresented: $showAddPlayerSheet, onDismiss: {
                    if let profile = currentProfile {
                        if sentRequestsList.contains(where: { $0.id == profile.id }) {
                            // Already had a pending sent request → just ensure it's in the copy
                            if !sentRequestsListCopy.contains(where: { $0.id == profile.id }) {
                                withAnimation(.easeInOut) {
                                    sentRequestsListCopy.append(profile)
                                }
                            }
                        } else if friendsListCopy.contains(where: { $0.id == profile.id }) {
                            // Mutual request auto-accepted on server → already a friend, nothing to do
                        } else {
                            // New request
                            withAnimation(.easeInOut) {
                                sentRequestsListCopy.append(profile)
                            }
                        }
                    }
                }) {
                    AddPlayersSheetView(
                        showAddPlayersSheet: $showAddPlayerSheet,
                        addPlayer: $currentProfile,
                        alreadyAdded: friendsListCopy.map { $0.profile } + sentRequestsListCopy ,
                        showGuest: .constant(false),
                        showPlayers: .constant(true),
                        showFriends: .constant(false),
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
            }.task {
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
            }else{
                if sentRequestsListCopy.count == 0 && requestedFriendsListCopy.count == 0{
                    Text("You have no friends yet. Request somebody!").listRowBackground(Color.clear).foregroundStyle(.secondary)
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
            if friendsListCopy.count > 0{
                TipView(ListSwipeFriendTip()).tipBackground(Color.clear)
            }
        }
        .task {
            do {
                try Tips.configure()
            } catch {
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    }
    
    private var sentRequestsHeader: some View {
        Section {
                HStack {
                    Text("Sent Requests").fontWeight(.bold)
                    Spacer()
                    if sentRequestsListCopy.count > 1 {
                        Menu {
                            Button {
                                withAnimation(.easeInOut) {
                                    sortBySentRequests = .nameDown
                                    friendsFilterActive = false
                                }
                            } label: {
                                if sortBySentRequests == .nameDown { Image(systemName: "checkmark") } else { Image("ABC.down") }
                                Text("Alphabetical (A-Z)")
                            }
                            Button {
                                withAnimation(.easeInOut) {
                                    sortBySentRequests = .nameUp
                                    friendsFilterActive = true
                                }
                            } label: {
                                if sortBySentRequests == .nameUp { Image(systemName: "checkmark") } else { Image("ABC.up") }
                                Text("Alphabetical (Z-A)")
                            }
                            Divider()
                            Button {
                                withAnimation(.easeInOut) {
                                    sortBySentRequests = .valueDown
                                    friendsFilterActive = true
                                }
                            } label: {
                                if sortBySentRequests == .valueDown { Image(systemName: "checkmark") } else { Image("Date.down") }
                                Text("Date Added (New - Old)")
                            }
                            Button {
                                withAnimation(.easeInOut) {
                                    sortBySentRequests = .valueUp
                                    friendsFilterActive = true
                                }
                            } label: {
                                if sortBySentRequests == .valueUp { Image(systemName: "checkmark") } else { Image("Date.up") }
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
        .listRowBackground(Color.clear)
    }
    
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
                    Button {
                        withAnimation(.easeInOut) {
                            
                            sentRequestsListCopy.removeAll { $0.id == request.id }
                        }
                    } label: {
                        Image(systemName: "person.badge.minus")
                        Text("Remove Request")
                    }
                    .tint(.red)
                }
            }
            
        }
        .task {
            do {
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

