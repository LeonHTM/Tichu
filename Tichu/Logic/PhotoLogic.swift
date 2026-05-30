//
// PhotoLogic.swift
//  Tichu
//
//  Created by Leon on 22.04.2026.
//

import Foundation
import SwiftUI
import UIKit
import LinkPresentation

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

final class ShareItem: NSObject, UIActivityItemSource {

    let title: String
    let message: String
    let image: UIImage?

    init(title: String, message: String, image: UIImage?) {
        self.title = title
        self.message = message
        self.image = image
    }

    // Placeholder
    func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        message
    }

    // Shared content
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {

        if let image {
            return image
        }

        return message
    }

    // Mail subject
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        title
    }

    // Rich preview
    func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {

        let metadata = LPLinkMetadata()
        metadata.title = title

        if let image {
            metadata.imageProvider = NSItemProvider(object: image)
        }

        return metadata
    }
}

// MARK: - Activity View Controller
struct ActivityViewController: UIViewControllerRepresentable {

    let title: String
    let message: String
    let image: UIImage?

    func makeUIViewController(context: Context) -> UIActivityViewController {

        let shareItem = ShareItem(
            title: title,
            message: message,
            image: image
        )

        return UIActivityViewController(
            activityItems: [shareItem],
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) { }
}


extension UIImage {
    func resized(to maxDimension: CGFloat) -> UIImage {
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if aspectRatio > 1 {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
