//
//  CameraPreview.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.configure(with: previewLayer)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // Nothing for now
    }

    final class PreviewView: UIView {
        private(set) var previewLayer: AVCaptureVideoPreviewLayer!

        func configure(with layer: AVCaptureVideoPreviewLayer) {
            self.previewLayer = layer
            self.layer.addSublayer(layer)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
        }
    }
}







