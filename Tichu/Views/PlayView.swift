//
//  PlayView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct PlayView: View {
    //Storage Usernames
    @State private var userProfile = Profile()
    @AppStorage("userName") var userName: String = "Unknown"
    @AppStorage("userElo") var userElo: Int = 1000
    @AppStorage("userImageData") private var userImageData: Data?
    @State private var userImage: UIImage?
    
    
    @State private var showAddPlayersSheet2:Bool = false
    @State private var showAddPlayersSheet3:Bool = false
    @State private var showAddPlayersSheet4:Bool = false
    
    @State private var showEditRoundsSheet: Bool = false
    @State private var showAddRoundSheet: Bool = false
    @State private var showDebugSheetView: Bool = false
    
    @State private var team1 = Team()
    @State private var team2 = Team()
    
    @State private var currentGame = tichuGame()
    
    @State private var currentRound =  Round()
    @FocusState private var targetFieldFocused: Bool
    @State private var showGameOverSheet = false
    
        
    private var isGameReady:Bool{
        currentGame.player2 != nil && currentGame.player3 != nil && currentGame.player4 != nil
    }
    
    private var gameDone :Bool{
        return currentGame.winner != nil
    }
    
    private var isRated: Bool {
            let players = [
                currentGame.player1,
                currentGame.player2,
                currentGame.player3,
                currentGame.player4
            ].compactMap { $0 }

          
            return !players.contains { $0.elo == nil }
        }
    

    
    var body: some View {
        ZStack{
            NavigationStack{
                
                List{
                    Section{
                        HStack{
                            Text("Team 1")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                           
                            if !isGameReady{
                                Text("Target:").multilineTextAlignment(.trailing).foregroundStyle(.secondary).offset(x:15)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    
                                TextField("",value: $currentGame.target, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 70)
                                    .font(.title2)
                                    .fontWeight(.bold).offset(x:6)
                                    .foregroundStyle(.secondary)
                                    .keyboardType(.numberPad)
                                    .focused($targetFieldFocused)
                                    .submitLabel(.done)
                                    .onSubmit { targetFieldFocused = false }
                            }
                            if isGameReady{
                                Text("\(currentGame.currentPointsTeam1)").font(.title2)
                                    .fontWeight(.bold)
                                    
                            }
                        } 
                        .listRowBackground(Color.clear)
                    }.padding(.top,65)
                    Section{
                        HStack{
                            VStack(alignment:.leading){
                                Text(userProfile.name ?? "Unknown")
                                    .fontWeight(.bold)
                                Text("Ranking: \(userProfile.elo ?? -69420)")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 16))
                            }
                            Spacer()
                            ProfileImage(selectedImage: userImage, size: 44)
                        }
                        if let name2 = currentGame.player2?.name  {
                            
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text(name2).fontWeight(.bold)
                                    if let elo = currentGame.player2?.elo {
                                        Text("Ranking: \(elo)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }else{
                                        Text("Download Tichu App to get ranked")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                 
                                    
                                }
                                Spacer()
                                if let data = currentGame.player2?.imageData,
                                   let uiImage = UIImage(data: data) {
                                    ProfileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    ProfileImage(selectedImage: nil, size: 44)
                                }
                                
                            }
                        }else{
                            HStack{
                                Spacer()
                                Image(systemName:"plus.circle.fill")
                                
                                VStack(alignment:.leading){
                                    
                                    
                                    Button("Add Player 2"){
                                        showAddPlayersSheet2 = true
                                    }
                                    .fontWeight(.bold).foregroundColor(.primary)
                                    .padding(.vertical,10.6)
                                    .sheet(isPresented: $showAddPlayersSheet2) {
                                        AddPlayersSheetView(
                                            showAddPlayersSheet: $showAddPlayersSheet2,
                                            addPlayer: $currentGame.player2,
                                            alreadyAdded: [
                                                currentGame.player3,
                                                currentGame.player4
                                            ].compactMap { $0 },
                                            showGuest: true,
                                            guestIndex: 2
                                        )
                                        .presentationDetents([.medium, .large])
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                                Spacer()
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    Section{
                        Spacer()
                    }.listRowBackground(Color.clear)
                    Section{
                        HStack{
                            Spacer()
                            
                            Spacer()
                            
                        }.padding(.vertical,isGameReady ? 37 : 60)
                    }.listRowBackground(Color.clear)
                    Section{
                        Spacer()
                    }.listRowBackground(Color.clear)
                    
                    Section{
                        HStack{
                            Text("Team 2")
                                
                            Spacer()
                            if isGameReady{
                                Text("\(currentGame.currentPointsTeam2)")
                            }
                        }
                    }.font(.title2)
                        .fontWeight(.bold)
                        .listRowBackground(Color.clear)
                    Section{
                        if let name3 = currentGame.player3?.name  {
                            
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text(name3).fontWeight(.bold)
                                    if let elo = currentGame.player3?.elo {
                                        Text("Ranking: \(elo)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }else{
                                        Text("Download Tichu App to get ranked")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                    
                                }
                                Spacer()
                                if let data = currentGame.player3?.imageData,
                                   let uiImage = UIImage(data: data) {
                                    ProfileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    ProfileImage(selectedImage: nil, size: 44)
                                }
                                
                            }
                        }else{
                            HStack{
                                Text("")
                                Spacer()
                                Image(systemName:"plus.circle.fill")
                                
                                VStack(alignment:.leading){
                                    
                                    
                                    Button("Add Player 3"){showAddPlayersSheet3 = true}.fontWeight(.bold).foregroundColor(.primary)
                                    
                                    
                                    
                                }.fontWeight(.bold).foregroundColor(.primary).padding(.vertical,10.6).sheet(isPresented: $showAddPlayersSheet3) {
                                    AddPlayersSheetView(
                                        showAddPlayersSheet: $showAddPlayersSheet3,
                                        addPlayer: $currentGame.player3,
                                        alreadyAdded: [
                                            currentGame.player2,
                                            currentGame.player4
                                        ].compactMap { $0 },
                                        showGuest: true,
                                        guestIndex:3
                                    )
                                    .presentationDetents([.medium, .large])
                                    
                                    
                                }
                                
                                Spacer()
                                
                            }
                            
                        }
                        if let name4 = currentGame.player4?.name {
                            
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text(name4).fontWeight(.bold)
                                    if let elo = currentGame.player4?.elo {
                                        Text("Ranking: \(elo)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }else{
                                        Text("Download Tichu App to get ranked")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                    
                                }
                                Spacer()
                                if let data = currentGame.player4?.imageData,
                                   let uiImage = UIImage(data: data) {
                                    ProfileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    ProfileImage(selectedImage: nil, size: 44)
                                }
                                
                            }
                        }else{
                            HStack{
                                Spacer()
                                Image(systemName:"plus.circle.fill")
                                
                                VStack(alignment:.leading){
                                    
                                    
                                    Button("Add Player 4"){
                                        showAddPlayersSheet4 = true
                                    }
                                    .fontWeight(.bold).foregroundColor(.primary)
                                    .sheet(isPresented: $showAddPlayersSheet4) {
                                        AddPlayersSheetView(
                                            showAddPlayersSheet: $showAddPlayersSheet4,
                                            addPlayer: $currentGame.player4,
                                            alreadyAdded: [
                                                currentGame.player2,
                                                currentGame.player3
                                            ].compactMap { $0 },
                                            showGuest: true,
                                            guestIndex: 4
                                        )
                                        .presentationDetents([.medium, .large])
                                        
                                    }
                                    
                                    
                                    
                                }.padding(.vertical,10.6)
                                
                                Spacer()
                                
                            }
                            
                        }
                    }
                    
                }.onChange(of: isGameReady) {
                    
                    // Build teams
                    if let _ = currentGame.player2?.name {
                        team1 = Team(list: [userProfile, currentGame.player2!],name: "Team 1")
                    }
                    if let _ = currentGame.player3?.name, let _ = currentGame.player4?.name {
                        team2 = Team(list: [currentGame.player3!, currentGame.player4!], name: "Team 2")
                    }
                    currentRound.team1 = team1
                    currentRound.team2 = team2
                    currentGame.team1 = team1
                    currentGame.team2 = team2
                }
                .onChange(of:gameDone){
                    if gameDone == true{
                        showGameOverSheet = true
                    }else if gameDone == false{
                        showGameOverSheet = false
                    }
                }
                .sheet(isPresented: $showGameOverSheet) {
                    GameSummarySheetView(showGameOverViewSheetView: $showGameOverSheet,currentGame:$currentGame,showRevancheButton:true
                                         ,HistoryMode:false).presentationDetents([.medium])
                    
                }
                .scrollContentBackground(.hidden)
                .background(alignment: .center) {
                    VStack{
                        
                       
                    HStack{
                        
                        
                        Text("VS")
                            .font(.system(size: 120, weight: .bold))
                            //.offset(y:-3)
                        //Text("S")
                            .font(.system(size: 120, weight: .bold))
                            //.offset(x:-15,y:3)
                    }
                        HStack{
                            Text(isRated ? "Rated" : "Unrated").fontWeight(.bold).font(.title2).offset(y:-15)
                            Text(isGameReady ? " \(currentGame.target)" : " ").fontWeight(.bold).font(.title2).offset(y:-15)
                        }
                }
                    .foregroundStyle(
                        Color.secondary
                      
                    ).onChange(of: isGameReady) {
                        
                        userProfile.name = userName
                        userProfile.elo = userElo
                        userProfile.imageData = userImageData
                        userImage = dataToPhoto(data: userProfile.imageData)
                        currentGame.player1 = userProfile
                    
                    }
                    .allowsHitTesting(false)
                }.edgesIgnoringSafeArea(.all).background(Color(uiColor: .systemGroupedBackground))
                .listSectionSpacing(0)
                .navigationTitle("Play")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar{
                    ToolbarItem(){
                        Button{
                            showDebugSheetView = true
                        }label:{
                            Image(systemName:"ant")
                        }
                    }
                    ToolbarItem(placement:.topBarTrailing){
                        ProfileImage(selectedImage: userImage, size: 44)
                        
                    }.sharedBackgroundVisibility(.hidden)
                    
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { targetFieldFocused = false }
                    }
                }
                
                
            }
        }.refreshable {
            
        }.sheet(isPresented: $showDebugSheetView){
            DebugSheetView(currentGame:$currentGame,showDebugSheetView: $showDebugSheetView,exampleGameHistory:.constant([]))
        }.safeAreaInset(edge:.bottom){
            if isGameReady == true{
                GlassEffectContainer{
                    HStack{
                        if currentGame.Rounds.count > 0 {
                            Button(){
                                showEditRoundsSheet = true
                            }label:{
                                Image(systemName: "list.bullet.badge.ellipsis")
                                    .font(.system(size: 20)).foregroundColor(.primary)
                                    .frame(width: 29, height: 29)
                                    .clipShape(Circle())
                            }.padding(10).glassEffect(.regular.interactive()).padding(.leading,20).padding(.bottom,10)
                                .sheet(isPresented: $showEditRoundsSheet) {
                                    EditRoundsSheetView(showEditRoundsSheet: $showEditRoundsSheet,currentGame:$currentGame).presentationDetents([.medium,.large])
                                    
                                }
                            
                        }else if currentGame.Rounds.count == 0{
                            Button {
                                currentGame = tichuGame()
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Game")
                                }
                                .foregroundColor(.primary)
                                .padding(13)
                                .glassEffect(.regular.interactive())
                            }
                            .padding(.bottom, 10).padding(.leading,20)
                        }
                        Spacer()
                      
                        Spacer()
                        Button(){
                            showAddRoundSheet = true
                        }label:{
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20)).foregroundColor(.primary)
                            Text("Add Round").foregroundColor(.primary)
                        }.padding(13).glassEffect(.regular.interactive()).padding(.trailing,20).padding(.bottom,10).sheet(isPresented: $showAddRoundSheet,onDismiss:{
                            currentRound = Round()
                        }) {
                            AddRoundSheetView(showAddRoundsSheet: $showAddRoundSheet,
                                              currentGame: $currentGame,
                                              currentRound: $currentRound,
                                              editMode:false,
                                              roundIndex: nil)
                                
                            
                        }
                        
                    }
                }
            }
        }.onAppear{
            userProfile.name = userName
            userProfile.elo = userElo
            userProfile.imageData = userImageData
            userImage = dataToPhoto(data: userProfile.imageData)
            currentGame.reCount()
   
        }
    }
       
       
 
        
        
                    
                
            
            
        
        }
        
           
    
    


#Preview {
    PlayView()
}

