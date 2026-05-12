//
//  EditFriendsSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI

struct EditFriendsSheetView: View {
    //Open/Close Sheet
    @Binding var showFriendsSheet:Bool
    
    @State private var friendsFilterActive:Bool = false
    @State private var sortByFriends: sortBy.sortBy = .nameDown
    @State private var sortByRequests: sortBy.sortBy = .nameDown
    //App Storage
    @AppStorage("userName") var userName: String = ""
    @Binding var friendsList: [Profile]
    @Binding var requestedFriendsList: [Profile]
    @State private var friendsListCopy: [Profile] = []
    @State var requestedFriendsListCopy: [Profile] = []
    @State private var currentFriend: Profile?
    @State private var showAddPlayerSheet: Bool = false
    @State private var currentProfile: Profile?
  
    var sortedFriendsList:[Profile]{
        makeItems(from: friendsListCopy, stat: .dateAdded, sortBy: sortByFriends)
    }
    
    var sortedRequestsList: [Profile]{
        makeItems(from: requestedFriendsListCopy, stat: .dateAdded, sortBy: sortByRequests)
    }
    var body: some View {
        
        NavigationStack{
            VStack(spacing:0){
                List{
                    if requestedFriendsListCopy.count > 0{
                        Section(){
                            
                            HStack{
                                
                                Text("Friend Requests").fontWeight(.bold)
                                Spacer()
                                if requestedFriendsListCopy.count > 1 {
                                    Menu {
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByRequests = .nameDown
                                                friendsFilterActive = false
                                            }
                                        } label: {
                                            if sortByRequests == .nameDown {
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("ABC.down")
                                            }
                                            Text("Alphabetical (A-Z)")
                                        }
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByRequests = .nameUp
                                                friendsFilterActive = true
                                            }
                                        } label: {
                                            if sortByRequests == .nameDown {
                                                Image("ABC.up")
                                            }else{
                                                Image(systemName:"checkmark")
                                            }
                                            Text("Alphabetical (Z-A)")
                                            
                                        }
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease.circle")
                                            .font(.system(size: 20))
                                    }
                                    .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                                }
                                
                            }
                        }.listRowBackground(Color.clear)
                        
                        Section{
                            ForEach(sortedRequestsList, id: \.id) { friend in
                                VStack{
                                    HStack{
                                        ProfileImage(data: friend.imageData, size: 44)
                                        VStack(alignment: .leading) {
                                            Text(friend.name ?? "Unknown")
                                            
                                            
                                        }
                                        
                                        
                                        Spacer()
                                        
                                        Spacer()
                                        GlassEffectContainer{
                                            HStack{
                                                Button{
                                                    withAnimation(.easeInOut) {
                                                        requestedFriendsListCopy.removeAll{ $0.id == friend.id
                                                        }
                                                    }
                                                }label:{
                                                    Image(systemName:"xmark")
                                                }.buttonStyle(BorderlessButtonStyle()).foregroundStyle(Color.primary).padding(13).glassEffect(.regular.interactive(),in: Circle())
                                                Button{
                                                    print("prk")
                                                    withAnimation(.easeInOut) {
                                                        requestedFriendsListCopy.removeAll{ $0.id == friend.id}
                                                        friendsListCopy.append(friend)}
                                                }label:{
                                                    Image(systemName:"checkmark")
                                                }.buttonStyle(BorderlessButtonStyle()).foregroundStyle(Color.white).padding(13).glassEffect(.regular.tint(.accentColor).interactive(),in:Circle())
                                                //FIX FOR BUTTONS NOT BEING CIRUCLAR
                                            }
                                        }
                                    }
                                    
                                    
                                }//.allowsHitTesting(false)
                                
                            }
                            
                            
                        }
                    }
                    Section(){
                        
                        HStack{
                            if friendsListCopy.count > 0{
                                Text("Friends").fontWeight(.bold)
                                Spacer()
                                if friendsListCopy.count > 1 {
                                    Menu {
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByFriends = .nameDown
                                                friendsFilterActive = false
                                            }
                                        } label: {
                                            if sortByFriends == .nameDown {
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("ABC.down")
                                            }
                                            Text("Alphabetical (A-Z)")
                                        }
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByFriends = .nameUp
                                                friendsFilterActive = true
                                            }
                                        } label: {
                                            if sortByFriends == .nameUp {
                                                Image(systemName:"checkmark")
                                                
                                            }else{
                                                Image("ABC.up")
                                            }
                                            Text("Alphabetical (Z-A)")
                                            
                                        }
                                        Divider()
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByFriends = .valueDown
                                                friendsFilterActive = true
                                            }
                                        } label: {
                                            if sortByFriends == .valueDown {
                                                Image(systemName:"checkmark")
                                                
                                            }else{
                                                Image("Date.down")
                                            }
                                            Text("Date Added (New - Old)")
                                            
                                        }
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByFriends = .valueUp
                                                friendsFilterActive = true
                                            }
                                        } label: {
                                            if sortByFriends == .valueUp{
                                                Image(systemName:"checkmark")
                                                
                                            }else{
                                                Image("Date.up")
                                            }
                                            Text("Date Added (Old - New)")
                                            
                                        }
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease.circle")
                                            .font(.system(size: 20))
                                    }
                                    .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                                }
                            }else{
                                
                            }
                        }
                    }.listRowBackground(Color.clear)
                    
                    Section{
                        ForEach(sortedFriendsList, id: \.id) { friend in
                            HStack{
                                ProfileImage(data: friend.imageData, size: 44)
                                VStack(alignment: .leading) {
                                    Text(friend.name ?? "Unknown")

                                    if let date = friend.dateAdded {
                                        Text("Friends since \(formattedDate(date))")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }else{
                                        Text("Requested Friendship").foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                }
                                
                                
                         
                               
                                
                            }.swipeActions(edge:.trailing){
                                    Button{
                                        withAnimation(.easeInOut) {
                                            friendsListCopy.removeAll { $0.id == friend.id }
                                        }
                                    }label:{
                                        Image(systemName:"person.badge.minus")
                                        Text(friend.isFriend == true ? "Remove Friend" : "Remove Request")
                                    }.tint(.red)
                                
                            }
                        }
                        
                    }
                    

                    Section{
                        Text("Friends can be added to a Tichu round without having to ask them first.").foregroundStyle(Color.secondary)
                    }.listRowBackground(Color.clear)
                }.onAppear{
                    friendsListCopy = friendsList
                    requestedFriendsListCopy = requestedFriendsList
                }
                .listSectionSpacing(0)
                .navigationTitle("Manage Friendlist")
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge:.bottom){
                    HStack{
                        Spacer()
                        Button{
                            showAddPlayerSheet = true
                        }label:{
                            Image(systemName:"plus")
                            Text("Request Friend")
                        }.foregroundStyle(Color.primary).padding(13).glassEffect(.regular.interactive())
                    }.padding(.horizontal)
                }.sheet(isPresented: $showAddPlayerSheet,onDismiss:{
                    if let profile = currentProfile{
                        withAnimation(.easeInOut) {
                            friendsListCopy.append(profile)
                        }
                    }
                }) {
                    AddPlayersSheetView(
                        showAddPlayersSheet: $showAddPlayerSheet,
                        addPlayer: $currentProfile,
                        alreadyAdded: sortedFriendsList,
                        showGuest: false,
                        showPlayers:true,
                        showFriends:false,
                        guestIndex: 0
                    )
                    .presentationDetents([.medium, .large])
                    
                }
                .toolbar{
                    ToolbarItem(placement:.confirmationAction){
                        Button("Done", systemImage: "checkmark"){
                            friendsList = friendsListCopy
                            requestedFriendsList = requestedFriendsListCopy
                            showFriendsSheet = false
                        }
                        
                    }
                    ToolbarItem(placement:.cancellationAction){
                        Button("Cancel",systemImage:"xmark"){
                            showFriendsSheet = false
                        }
                    }
                }
            }
        }
        
    }
}


#Preview {
    EditFriendsSheetView(showFriendsSheet: .constant(true), friendsList: .constant(exampleFriends),requestedFriendsList:.constant([exampleGring]))
}

