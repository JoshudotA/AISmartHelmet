//
//  DetectionOverlay.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//
import SwiftUI
import Vision

struct DetectionOverlay: View {
    let observations: [VNRecognizedObjectObservation]
    let frameSize: CGSize

    var body: some View {
        ZStack {
            ForEach(observations, id: \.uuid) { obs in
                let rect = convert(obs.boundingBox, in: frameSize)

                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .allowsHitTesting(false)
    }



    private func convert(_ bbox: CGRect, in size: CGSize) -> CGRect {
        let w = size.width
        let h = size.height

        return CGRect(
            x: bbox.minX * w,
            y: (1 - bbox.minY - bbox.height) * h,
            width: bbox.width * w,
            height: bbox.height * h
        )
    }


}







