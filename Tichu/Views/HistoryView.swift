//
//  HistoryView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct HistoryView: View {
    //Storage
    @AppStorage("userImageData") private var userImageData: Data?
    //Vars
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack{
            HStack{
                Text("History")
                Image(systemName:"clock")
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("History")
            .toolbar{
                ToolbarItem(placement:.topBarTrailing){
                    profileImage(selectedImage: selectedImage, size: 44)
                        
                }.sharedBackgroundVisibility(.hidden)
                    
            }
        }.onAppear {
            selectedImage = dataToPhoto(data:userImageData)
        }
    }
}

#Preview {
    HistoryView()
}
