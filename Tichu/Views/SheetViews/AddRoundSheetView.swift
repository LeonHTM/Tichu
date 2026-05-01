//
//  AddRoundSheetView.swift
//  Tichu
//
//  Created by Leon on 27.04.2026.
//




//MOCKUP UI
import SwiftUI

struct AddRoundSheetView: View {
    
    @State private var tichuTags: [String] = ["Tichu","Big Tichu","Pingu",]
    @State private var selectedTags: [String] = []
    @State private var tichuPointsTeam1: Double = 0
    
    @Binding var showAddRoundsSheet: Bool
    
    var tichuPointsTeam2: Double{
        100 - tichuPointsTeam1
    }
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    GlassEffectContainer{
                        VStack(alignment:.leading){
                            Text("Team 1").font(.title2).fontWeight(.bold).padding(.leading,10)
                            Text("Leon").font(.title3).padding(.leading,12)
                            HStack{
                                Button{
                                    
                                }label:{
                                    Text("t").foregroundColor(.primary)
                                }.padding(10).glassEffect(.regular.interactive())
                                Button{
                                    
                                }label:{
                                    //Deutsch : Gr. Tichu
                                    Text("T").foregroundColor(.primary)
                                }.padding(10).glassEffect(.regular.interactive())
                                Button{
                                    
                                }label:{
                                    Text("P").foregroundColor(.primary)
                                }.padding(10).glassEffect(.regular.interactive())
                            }
                            HStack{
                                
                                Button{
                                    
                                }label:{
                                    Text("Bombs: 0").foregroundColor(.primary)
                                }.padding(.vertical,10).padding(.horizontal,16).glassEffect(.regular.interactive())
                            }
                            VStack(alignment:.leading){
                            Text("Sorin").font(.title3).padding(.leading,12)
                            HStack{
                                Button{
                                    
                                }label:{
                                    Text("Tichu").foregroundColor(.primary)
                                }.padding(10).glassEffect(.regular.interactive())
                                Button{
                                    
                                }label:{
                                    //Deutsch : Gr. Tichu
                                    Text("Big Tichu").foregroundColor(.primary)
                                }.padding(10).glassEffect(.regular.interactive())
                            }
                            HStack{
                                Button{
                                    
                                }label:{
                                    Text("Pingu").foregroundColor(.primary)
                                }.padding(10).glassEffect(.regular.interactive())
                                Button{
                                    
                                }label:{
                                    Text("Bombs: 0").foregroundColor(.primary)
                                }.padding(10).glassEffect(.regular.interactive())
                            }
                            }.padding(10).background(.gray.opacity(0.175), in: .rect(cornerRadius: 24))
                        }
                    }
                    Divider().padding(.horizontal,5)
                    GlassEffectContainer{
                    VStack(alignment:.leading){
                        Text("Team 2").font(.title2).fontWeight(.bold).padding(.leading,10)
                        VStack(alignment:.leading){
                        Text("Luis").font(.title3).padding(.leading,12)
                        HStack{
                            Button{
                                
                            }label:{
                                Text("Tichu").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                            Button{
                                
                            }label:{
                                //Deutsch : Gr. Tichu
                                Text("Big Tichu").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                        }
                        HStack{
                            Button{
                                
                            }label:{
                                Text("Pingu").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                            Button{
                                
                            }label:{
                                Text("Bombs: 0").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                        }
                        }.padding(10).background(.gray.opacity(0.175), in: .rect(cornerRadius: 24))
                        Text("Jo").font(.title3).padding(.leading,12)
                        HStack{
                            Button{
                                
                            }label:{
                                Text("Tichu").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                            Button{
                                
                            }label:{
                                //Deutsch : Gr. Tichu
                                Text("Big Tichu").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                        }
                        HStack{
                            Button{
                                
                            }label:{
                                Text("Pingu").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                            Button{
                                
                            }label:{
                                Text("Bombs: 0").foregroundColor(.primary)
                            }.padding(10).glassEffect(.regular.interactive())
                        }
                    }
                }
                }.zIndex(3)
                List{
                    HStack{
                        Text("1.").fontWeight(.bold)
                        Text("Sorin")
                    }
                    HStack{
                        Text("2.").fontWeight(.bold)
                        Text("Leon")
                        Spacer()
                        Menu{
                            Button{
                                
                            }label:{
                                Image(systemName:"exclamationmark.circle")
                                Text("Tichu")
                            }
                            Button{
                                
                            }label:{
                                Image("exclamationmark.2.circle")
                                Text("Big Tichu")
                            }
                            Button{
                                
                            }label:{
                                Image("exclamationmark.3.circle")
                                Text("Pingu")
                            }
                        }label:{
                            Text("Announcement").foregroundColor(.primary)
                            
                        }.padding(.trailing,10)
                        Image(systemName:"line.3.horizontal")
                        
                    }
                    HStack{
                        Text("3.").fontWeight(.bold)
                        Text("Jo")
                    }
                    HStack{
                        Text("4.").fontWeight(.bold)
                        Text("Luis")
                    }
              
                }.listSectionSpacing(0).padding(.top,-32).zIndex(2).scrollDisabled(true)
                HStack{
                    VStack(alignment:.leading){
                        Text("Points").font(.title2).fontWeight(.bold)
                        Slider(
                                    value: $tichuPointsTeam1,
                                    in: -25...125,
                                    
                                )
                        Text("+ 25 from Tichu")
                        Text("+ 100 from Announcing")
                    }.padding(.horizontal)
                    Divider()
                    VStack(alignment:.leading){
                        Text("Points").font(.title2).fontWeight(.bold)
                        Slider(
                                    value: $tichuPointsTeam1,
                                    in: -25...125,
                                    
                                )
                        Text("+ 25 from Tichu")
                        Text("+ 100 from Announcing")
                    }.padding(.horizontal)
                }.zIndex(0).padding(.vertical,10)
            }.navigationTitle("Add Round")
                .navigationBarTitleDisplayMode(.inline)

                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            showAddRoundsSheet = false
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            showAddRoundsSheet = false
                        }
                    }
                }
            
        }
        
        }
}

#Preview {
    AddRoundSheetView(showAddRoundsSheet: .constant(true))
}
