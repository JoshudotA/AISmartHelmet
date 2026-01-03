//
//  YOLODetector.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//
import Foundation
import Vision
import CoreML

final class YOLODetector: @unchecked Sendable {
    private let visionModel: VNCoreMLModel

    init() {
        guard let url = Bundle.main.url(forResource: "best", withExtension: "mlmodelc"),
              let mlModel = try? MLModel(contentsOf: url),
              let vnModel = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Failed to load YOLOv8 Core ML model")
        }

        self.visionModel = vnModel
    }

    nonisolated func detect(pixelBuffer: CVPixelBuffer) async -> [VNRecognizedObjectObservation] {
        let request = VNCoreMLRequest(model: visionModel)
        request.imageCropAndScaleOption = .scaleFill

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .up,   // ALWAYS .up because buffer is already rotated
            options: [:]
        )

        do {
            try handler.perform([request])
            return (request.results as? [VNRecognizedObjectObservation] ?? []).map { $0 }
        } catch {
            print("Vision error:", error)
            return []
        }
    }
}






