//
//  TestView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI
import TipKit



struct TestView: View {
   
    var favoriteLandmarkTip = ListSwipeTip()

        var body: some View {
            VStack{
                Text("SORIN BRAKKA")
                TipView(favoriteLandmarkTip, arrowEdge: .top)
            }.task {
                // Configure and load your tips at app launch.
                do {
                    try Tips.configure()
                }
                catch {
                    // Handle TipKit errors
                    print("Error initializing TipKit \(error.localizedDescription)")
                }
            }
            
        }
}
       

#Preview {
    TestView()
}
