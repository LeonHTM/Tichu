//
// photoLogic.swift
//  Tichu
//
//  Created by Leon on 22.04.2026.
//

import Foundation
import SwiftUI
import UIKit
//From stored data do UIImage
func dataToPhoto(data: Data?) -> UIImage? {
    if let data,
       let image = UIImage(data: data) {
        return image
    }
    return nil
}
            
   


//Render photo from UIImage + Fallback if no photo exists
@ViewBuilder
func profileImage(selectedImage: UIImage?, size: Int) -> some View {
    let size = CGFloat(size)
    if let selectedImage {
        Image(uiImage: selectedImage)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }else {
        Image(systemName:"person.circle.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(.secondary)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}


