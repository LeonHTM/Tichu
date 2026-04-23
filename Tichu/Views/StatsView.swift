//
//  StatsView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct StatsView: View {
    //Storage
    @AppStorage("userImageData") private var userImageData: Data?
    //Vars
    @State private var selectedImage: UIImage?
    @State private var timeTags: [String] = ["All Time","Year","Month","Week","Today","Add Players for comparison"]
    @State private var selectedTags: [String] = []
    
    var body: some View {
        NavigationStack {
            List {
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
                Text("soo")
            }
            .padding(.top,-30)
            .navigationTitle("Statistics")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    profileImage(selectedImage: selectedImage, size: 44)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .safeAreaInset(edge: .top) {
                ChipsView(tags: timeTags) { tag, isSelected in
                    ChipView(tag, isSelected: isSelected)
                }didChangeSelection: { selection in
                    selectedTags = selection
                }
                .padding(.leading, 10)
               
            }
        }.onAppear {
            selectedImage = dataToPhoto(data:userImageData)
        }
        
    }
}

#Preview {
    StatsView()
}
