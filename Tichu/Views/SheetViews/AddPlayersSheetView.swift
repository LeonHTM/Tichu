//
//  FriendsSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI

struct AddPlayersSheetView: View {
    //Open/Close Sheet
    @Binding var showAddPlayersSheet:Bool
    var showGuest: Bool
    @State private var friendsFilterActive: Bool = false
    @State private var playersFilterActive: Bool = false
  
    
    var body: some View {
        
        NavigationStack{
            
            List{
                if showGuest == true{
                    Section{
                        HStack{
                            Button("Guest"){
                                showAddPlayersSheet = false
                            }.foregroundStyle(.white)
                            Spacer()
                            profileImage(selectedImage: nil, size: 44)
                        }
                    }
                }
                Section{
                    Section{
                        HStack{
                            Text("Friends").fontWeight(.bold)
                            Spacer()
                            Menu {
                                Button() {
                                    friendsFilterActive.toggle()
                                }label:{
                                    Image("ABC.down")
                                    Text("Alphabetical (A-Z)")
                                }
                                Button() {
                                    friendsFilterActive.toggle()
                                }label:{
                                    Image("ABC.up")
                                    Text("Alphabetical (Z-A)")
                                    
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 20))
                            }
                           .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                        }.padding(.top,20)
                    }.listRowBackground(Color.clear)
                }.listRowBackground(Color.clear)
                HStack{
                    
                    Button("Platzhalter"){
                        showAddPlayersSheet = false
                    }.foregroundColor(.primary)
                    Spacer()
                    profileImage(selectedImage: nil, size: 44)
                    
                }
                Section{
                    HStack{
                        Text("All Players").fontWeight(.bold)
                        Spacer()
                        Menu {
                            Button() {
                                playersFilterActive.toggle()
                            }label:{
                                Image("ABC.down")
                                Text("Alphabetical (A-Z)")
                            }
                            Button() {
                                playersFilterActive.toggle()
                            }label:{
                                Image("ABC.up")
                                Text("Alphabetical (Z-A)")
                                
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 20))
                        }
                       .foregroundColor(playersFilterActive ? .accentColor : .primary)
                    }.padding(.top,20)
                }.listRowBackground(Color.clear)
                HStack{
                    
                    Button("Platzhalter"){
                        showAddPlayersSheet = false
                    }.foregroundColor(.primary)
                    Spacer()
                    profileImage(selectedImage: nil, size: 44)
                    
                }
                
                
            }
            .listSectionSpacing(0)

            
            
            .listRowSpacing(2)
            .navigationTitle("Add Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                                ToolbarItem(placement:.cancellationAction){
                    Button("Cancel",systemImage:"xmark"){
                        showAddPlayersSheet = false
                    }
                }
            }
        }.onAppear{
            
        }
        
    }
}


#Preview {
    AddPlayersSheetView(showAddPlayersSheet: .constant(true),showGuest:true)
}
