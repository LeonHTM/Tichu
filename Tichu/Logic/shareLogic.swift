//
//  GameLogic.swift
//  Tichu
//
// Created by Leon on 01.06.2026.
//

import SwiftUI
import UIKit

struct GameShareHelper {
    let currentGameId: Int?
    let network: NetworkService
    let profiles: [Profile]
    let colorScheme: ColorScheme
    let displayScale: CGFloat

    func renderShareImage() -> UIImage? {
        let rounds = network.roundsByGame[currentGameId ?? 0] ?? []
        let shareView = GameSummaryShareView(
            currentGameId: currentGameId,
            rounds: rounds,
            profiles: profiles,
            accentCo: .accent
        )
        .tint(Color.accentColor)
        .environment(\.colorScheme, colorScheme)
        .background(colorScheme == .dark ? Color.black : Color.white)

        let renderer = ImageRenderer(content: shareView)
        renderer.colorMode = .nonLinear
        renderer.proposedSize = ProposedViewSize(width: 500, height: 750)
        renderer.scale = displayScale

        guard let cgImage = renderer.cgImage else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)

        guard let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))

        guard let opaqueCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: opaqueCGImage, scale: displayScale, orientation: .up)
    }

    func shareImage(completion: @escaping (UIImage) -> Void) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        UserDefaults.standard.set(true, forKey: "isLoadingShare")
        Task.detached(priority: .userInitiated) {
            guard let image = self.renderShareImage() else {
                await MainActor.run { UserDefaults.standard.set(false, forKey: "isLoadingShare") }
                return
            }
            await MainActor.run {
                UserDefaults.standard.set(false, forKey: "isLoadingShare")
                completion(image)
            }
        }
    }
}
