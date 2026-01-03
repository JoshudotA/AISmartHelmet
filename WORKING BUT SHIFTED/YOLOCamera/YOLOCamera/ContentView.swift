//
//  ContentView.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var previewLayer: AVCaptureVideoPreviewLayer?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let layer = previewLayer {
                    CameraPreview(previewLayer: layer)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea()
                }

                DetectionOverlay(
                    observations: viewModel.detections,
                    frameSize: geo.size
                )

                .ignoresSafeArea()
            }
            .onAppear {
                if previewLayer == nil {
                    previewLayer = viewModel.makePreviewLayer()
                }
            }
        }
    }
}










