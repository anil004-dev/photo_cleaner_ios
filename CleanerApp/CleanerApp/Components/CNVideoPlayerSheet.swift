//
//  CNVideoPlayerSheet.swift
//  CleanerApp
//
//  Created by iMac on 29/01/26.
//


import SwiftUI
import AVKit

struct CNAVPlayerView: View {
    let player: AVPlayer
    let onDismiss: (() -> Void)
    
    var body: some View {
        NavigationStack {
            ZStack {
                CNAVPlayerControllerRepresentable(player: player)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                player.play()
            }
            .onDisappear {
                player.pause()
            }
        }
    }
}

struct CNAVPlayerControllerRepresentable: UIViewControllerRepresentable {
    
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.modalPresentationStyle = .fullScreen
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) { }
}
