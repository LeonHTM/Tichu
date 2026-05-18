//
// PhotoLogic.swift
//  Tichu
//
//  Created by Leon on 22.04.2026.
//

import Foundation
import SwiftUI
import UIKit

//MARK: - From stored data do UIImage
func dataToPhoto(data: Data?) -> UIImage? {
   
    if let data,
       let image = UIImage(data: data) {
        return image
    }
    return nil
}
            
//MARK: - Render photo from UIImage + Fallback if no photo exists
@ViewBuilder
func ProfileImage(data: Data?, size: Int) -> some View {
    
    let size = CGFloat(size)
    if let data, let uiImage = dataToPhoto(data: data) {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    } else {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(.secondary)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

// MARK: - Activity View Controller
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension UIImage: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}
