//
//  Tips.swift
//  Tichu
//
//  Created by Leon on 13.05.2026.
//

import SwiftUI
import TipKit



struct ListSwipeTip: Tip {
    var title: Text {
        Text("Swipe Left to Edit")
    }


    var message: Text? {
        Text("Swipe left on a Round to edit and/or delete it.")
    }


    var image: Image? {
        Image(systemName: "arrow.left.circle")
    }
}

struct ListSwipeFriendTip: Tip {
    var title: Text {
        Text("Swipe Left to Remove")
    }


    var message: Text? {
        Text("Swipe left on a a Friend to remove.")
    }


    var image: Image? {
        Image(systemName: "arrow.left.circle")
    }
}
struct HistoryTapTip: Tip {
    var title: Text {
        Text("Tap to show more Information")
    }


    var message: Text? {
        Text("Tap on the View below to see more Information about the Round and share it")
    }


    var image: Image? {
        Image(systemName: "hand.tap")
    }
}

#Preview{
    TestView()
}
