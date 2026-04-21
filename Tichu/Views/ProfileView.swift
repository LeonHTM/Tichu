//
//  ProfileView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack{
            List {
                HStack{
                    Spacer()
                    VStack{
                        Image("pfp")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(.circle)
                        
                        Text("LeonHTM")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top,10)
                        
                        Text("Elo: 2400").foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                
                Section{
                    Button{
                        print("Change Username")
                    }label: {
                        HStack{
                            Image(systemName:"person")
                            Text("Change Username").foregroundStyle(.white)
                        }
                    }
                    Button{
                        print("Change Profile Picture")
                    }label: {
                        HStack{
                            Image(systemName:"photo")
                            Text("Change Profile Picture").foregroundStyle(.white)
                        }
                    }
                    Button{
                        print("Contact")
                    }label: {
                        HStack{
                            Image(systemName:"envelope")
                            Text("Contact").foregroundStyle(.white)
                        }
                    }
                    
                    Button{
                        print("Privacy")
                    }label: {
                        HStack{
                            Image(systemName:"lock.shield.fill")
                            Text("Privacy").foregroundStyle(.white)
                        }
                    }
                    
                }
                
                Section{
                    Button{
                        print("Delete Account")
                    }label: {
                        HStack{
                            Image(systemName:"trash").foregroundStyle(.red)
                            Text("Delete Account").foregroundStyle(.white)
                        }
                    }
                    Button{
                        print("Log Out")
                    }label: {
                        HStack{
                            Image(systemName:"rectangle.portrait.and.arrow.right")
                            Text("Swtich Account").foregroundStyle(.white)
                        }
                    }
                    Button{
                        print("Log out")
                    }label: {
                        HStack{
                            Image(systemName:"rectangle.portrait.and.arrow.right")
                            Text("Log Out").foregroundStyle(.white)
                        }
                    }
                    
                }
                HStack{
                    Spacer()
                    VStack{
                        Text("Made with ❤️ in Bern")
                        Text("Version 1.0 Build 1")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                }.listRowBackground(Color.clear)
            }
            .navigationTitle("Profile")
            .toolbarTitleDisplayMode(.inlineLarge)
            
            
        }
                
        

    }
}

#Preview {
    ProfileView()
}
