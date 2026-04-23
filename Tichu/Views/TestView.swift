//
//  TestView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI

struct TestView: View {
    private let tags: [String] = ["All Time","Year","Month","Week","Today"]
   
    var body: some View {
        NavigationStack {
            ChipsView(tags: tags) { tag, isSelected in
                ChipView(tag, isSelected: isSelected)
            } didChangeSelection: { selection in
               print(selection)
            }
            .padding(10)
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 20))
            .navigationTitle("Test View")
        }
        .padding(15)
    }
}
       

#Preview {
    TestView()
}
