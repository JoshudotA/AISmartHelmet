//
//  CameraManager.swift
//  YOLOCamera
//
//  Created by Joshua Lin on 12/5/25.
//

import AVFoundation
import UIKit
import Combine
protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput pixelBuffer: CVPixelBuffer)
}

final class CameraManager: NSObject {
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")

    private let videoOutput = AVCaptureVideoDataOutput()

    weak var delegate: CameraManagerDelegate?
    weak var previewLayer: AVCaptureVideoPreviewLayer?

    @Published var currentAngle: CGFloat = 90

    override init() {
        super.init()

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.previewLayer = layer
        return layer
    }

    func start() {
        sessionQueue.async {
            guard !self.session.isRunning else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard
                let device = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: .back
                ),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)

            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoOutputQueue"))
            self.videoOutput.alwaysDiscardsLateVideoFrames = true

            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }

            self.updateVideoRotationAngle()

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    @objc private func deviceOrientationDidChange() {
        updateVideoRotationAngle()
    }

    private func updateVideoRotationAngle() {
        sessionQueue.async {
            let deviceOrientation = UIDevice.current.orientation
            let angle: CGFloat

            switch deviceOrientation {
            case .portrait:
                angle = 90
            case .portraitUpsideDown:
                angle = 90
            case .landscapeLeft:
                angle = 0
            case .landscapeRight:
                angle = 180
            default:
                return
            }

            self.currentAngle = angle

            if let videoConnection = self.videoOutput.connection(with: .video),
               videoConnection.isVideoRotationAngleSupported(angle) {
                videoConnection.videoRotationAngle = angle
            }

            if let plConnection = self.previewLayer?.connection,
               plConnection.isVideoRotationAngleSupported(angle) {
                plConnection.videoRotationAngle = angle
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        Task { @MainActor in
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            delegate?.cameraManager(self, didOutput: pixelBuffer)
        }
    }
}




