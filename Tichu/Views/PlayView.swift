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
    
    
    //Vars
    @State private var userImage: UIImage?
    @State private var player2Image: UIImage?
    @State private var player3Image: UIImage?
    @State private var player4Image: UIImage?
    
    @State private var player2 = profile()
    @State private var player3 = profile()
    @State private var player4 = profile()
    
    @State private var showAddPlayersSheet2:Bool = false
    @State private var showAddPlayersSheet3:Bool = false
    @State private var showAddPlayersSheet4:Bool = false
    
    @State private var showEditRoundsSheet: Bool = false
    @State private var showAddRoundSheet: Bool = false
    
    @State private var team1 = Team()
    @State private var team2 = Team()
    
    @State private var currentGame = tichuGame()
    @State private var currentRound =  Round()
        
    private var isGameReady:Bool{
        player2.name != nil && player3.name != nil && player4.name != nil
    }
    
    var body: some View {
        ZStack{
            NavigationStack{
                
                List{
                    Section{Text("Team 1")
                            .font(.title2)
                            .fontWeight(.bold)
                        .listRowBackground(Color.clear)}
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
                        if let name2 = player2.name {
                            
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text(name2).fontWeight(.bold)
                                    if let elo = player2.elo {
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
                                if let data = player2.imageData,
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
                                        AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet2,addPlayer:$player2,alreadyAdded:[player3,player4],showGuest:true).presentationDetents([.medium,.large])
                                        
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
                    
                    Section{Text("Team 2")
                            .font(.title2)
                            .fontWeight(.bold)
                        .listRowBackground(Color.clear)}
                    Section{
                        if let name3 = player3.name  {
                            
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text(name3).fontWeight(.bold)
                                    if let elo = player3.elo {
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
                                if let data = player3.imageData,
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
                                    AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet3,addPlayer:$player3,alreadyAdded:[player2,player4],showGuest:true).presentationDetents([.medium,.large])
                                    
                                }
                                
                                Spacer()
                                
                            }
                            
                        }
                        if let name4 = player4.name {
                            
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text(name4).fontWeight(.bold)
                                    if let elo = player4.elo {
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
                                if let data = player4.imageData,
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
                                        AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet4,addPlayer:$player4,alreadyAdded:[player2,player3],showGuest:true).presentationDetents([.medium,.large])
                                        
                                    }
                                    
                                    
                                    
                                }.padding(.vertical,10.6)
                                
                                Spacer()
                                
                            }
                            
                        }
                    }
                    
                }.onChange(of: isGameReady) {
                    
                    // Build teams
                    if let _ = player2.name {
                        team1 = Team(list: [userProfile, player2])
                    }
                    if let _ = player3.name, let _ = player4.name {
                        team2 = Team(list: [player3, player4])
                    }
                    currentRound.team1 = team1
                    currentRound.team2 = team2
                    currentGame.team1 = team1
                    currentGame.team2 = team2
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
                    )
                    .allowsHitTesting(false)
                }.background(Color(uiColor: .systemGroupedBackground))
                .listSectionSpacing(0)
                .padding(.top,-40)
                .navigationTitle("Play")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar{
                    ToolbarItem(placement:.topBarTrailing){
                        profileImage(selectedImage: userImage, size: 44)
                        
                    }.sharedBackgroundVisibility(.hidden)
                    
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
                            
                        }
                        Spacer()
                        Button(){
                            
                        }label:{
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20)).foregroundColor(.primary)
                            Text("Add Round").foregroundColor(.primary)
                        }.padding(13).glassEffect(.regular.interactive()).padding(.trailing,20).padding(.bottom,10)
                    }
                }
            }
        }.onAppear{
            userProfile.name = userName
            userProfile.elo = userElo
            userProfile.imageData = userImageData
            userImage = dataToPhoto(data:userProfile.imageData)
        }
    }
       
       
 
        
        
                    
                
            
            
        
        }
        
           
    


#Preview {
    PlayView()
}

