//
//  profileLogic.swift
//  Tichu
//
//  Created by Leon on 25.04.2026.
//

import SwiftUI

struct Profile: Identifiable {
    let id = UUID()
    let name: String?
    let imageData: Data?
    let isFriend: Bool
}

