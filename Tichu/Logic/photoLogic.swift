//
//  structs.swift
//  Tichu
//
//  Created by Leon on 22.04.2026.
//

import Foundation
import SwiftUI
import UIKit

func dataToPhoto(data: Data) -> UIImage? {
    UIImage(data: data)
}

@ViewBuilder
func ProfileImage(Image selectedImage: UIImage?,size: CGFloat) -> some View {
    if let selectedImage {
        Image(uiImage: selectedImage)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    } else {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(.secondary)
    }
}


