//
//  CameraViewModel.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 1/2/26.
//
import Foundation
import AVFoundation
import Vision
import Combine

final class CameraViewModel: ObservableObject {
    @Published var detections: [VNRecognizedObjectObservation] = []

    let cameraManager = CameraManager()
    private let detector = YOLODetector()
    private var isProcessing = false

    init() {
        cameraManager.delegate = self
        cameraManager.start()
    }

    deinit {
        cameraManager.stop()
    }

    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        cameraManager.makePreviewLayer()
    }
    
    var rotationAngle: CGFloat {
        cameraManager.currentAngle
    }
    
    private func handleFrame(_ pixelBuffer: CVPixelBuffer) {
        guard !isProcessing else { return }
        isProcessing = true

        Task {
            // Vision should always receive .up because AVFoundation already rotated the buffer
            let results = await detector.detect(pixelBuffer: pixelBuffer)

            await MainActor.run {
                self.detections = results
                self.isProcessing = false
            }
        }
    }
}

extension CameraViewModel: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didOutput pixelBuffer: CVPixelBuffer) {
        handleFrame(pixelBuffer)
    }
}



