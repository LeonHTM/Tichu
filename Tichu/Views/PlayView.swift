//
//  PlayView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct PlayView: View {
    //Storage Usernames
    @State private var userProfile = profile()
    @AppStorage("userName") var userName: String = "Unknown"
    @AppStorage("userElo") var userElo: Int = 1000
    @AppStorage("userImageData") private var userImageData: Data?
    @State private var userImage: UIImage?
    
    
    
    @State private var showAddPlayersSheet2:Bool = false
    @State private var showAddPlayersSheet3:Bool = false
    @State private var showAddPlayersSheet4:Bool = false
    
    @State private var showEditRoundsSheet: Bool = false
    @State private var showAddRoundSheet: Bool = false
    
    @State private var team1 = Team()
    @State private var team2 = Team()
    
    @State private var currentGame:tichuGame = exampleGame
    @State private var currentRound =  Round()
    @FocusState private var targetFieldFocused: Bool
    @State private var showGameOverSheet = false
    
    
    
    var gameDone:Bool{
        if currentGame.currentPointsTeam1 >= currentGame.target || currentGame.currentPointsTeam2 >= currentGame.target{
            if currentGame.currentPointsTeam1 > currentGame.currentPointsTeam2{
                return true
            }else if currentGame.currentPointsTeam2 > currentGame.currentPointsTeam1{
                return true
            }
            
        }
        return false
        
    }
        
    private var isGameReady:Bool{
        currentGame.player2 != nil && currentGame.player3 != nil && currentGame.player4 != nil
    }
    
    func checkGameOver() {
        showGameOverSheet = gameDone
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
                                Text("Target:").multilineTextAlignment(.trailing).foregroundStyle(.secondary)
                                TextField("",value: $currentGame.target, format: .number)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
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
                            profileImage(selectedImage: userImage, size: 44)
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
                                    profileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    profileImage(selectedImage: nil, size: 44)
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
                                    profileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    profileImage(selectedImage: nil, size: 44)
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
                                    profileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    profileImage(selectedImage: nil, size: 44)
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
                        team1 = Team(list: [userProfile, currentGame.player2!])
                    }
                    if let _ = currentGame.player3?.name, let _ = currentGame.player4?.name {
                        team2 = Team(list: [currentGame.player3!, currentGame.player4!])
                    }
                    currentRound.team1 = team1
                    currentRound.team2 = team2
                    currentGame.team1 = team1
                    currentGame.team2 = team2
                }.onChange(of: currentGame.currentPointsTeam1) {
                    checkGameOver()
                }

                .onChange(of: currentGame.currentPointsTeam2) {
                    checkGameOver()
                }.sheet(isPresented: $showGameOverSheet) {
                    GameOverViewSheetView(showGameOverViewSheetView: $showGameOverSheet,currentGame:$currentGame).presentationDetents([.medium])
                    
                }
                .scrollContentBackground(.hidden)
                .background(alignment: .center) {
                    HStack{
                Text("V")
                    .font(.system(size: 120, weight: .bold))
                    .offset(y:-3)
                        Text("S")
                    .font(.system(size: 120, weight: .bold))
                    .offset(x:-15,y:3)
                    }
                    .foregroundStyle(
                        Color.secondary
                        /*
                        LinearGradient(
                            
                            colors: [Color.red, Color.green],
                            startPoint: .top,
                            endPoint: .bottom
                        )*/
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
                //.padding(.top,-40)
                .navigationTitle("Play")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar{
                    ToolbarItem(placement:.topBarTrailing){
                        profileImage(selectedImage: userImage, size: 44)
                        
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
                        Button(){
                            showAddRoundSheet = true
                        }label:{
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20)).foregroundColor(.primary)
                            Text("Add Round").foregroundColor(.primary)
                        }.padding(13).glassEffect(.regular.interactive()).padding(.trailing,20).padding(.bottom,10).sheet(isPresented: $showAddRoundSheet) {
                            AddRoundSheetView(showAddRoundsSheet: $showAddRoundSheet,currentGame: $currentGame,currentRound: $currentRound,editMode:false)
                            
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

