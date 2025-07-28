//
//  BarcodeScannerViewModel.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI
import AVFoundation
import UIKit
import Firebase
import FirebaseFirestore


class BarcodeScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedBarcode: String?
    @Published var showPermissionAlert = false
    @Published var isTorchOn = false
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var metadataOutput = AVCaptureMetadataOutput()
    private var device: AVCaptureDevice?
    private var isSessionConfigured = false
    private var shouldResumeOnAppear = false
    
    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if !granted {
                        self?.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }
    
    func setupCaptureSession(view: UIView) {
        if isSessionConfigured {
            return
        }
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              let captureSession = captureSession else {
            return
        }
        
        self.device = videoCaptureDevice
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8,
                .ean13,
                .pdf417,
                .qr,
                .code39,
                .code93,
                .code128,
                .upce
            ]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        isSessionConfigured = true
    }
    
    func startCapture() {
        guard isSessionConfigured, let captureSession = captureSession, !captureSession.isRunning else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            print("Camera capture session started")
        }
    }
    
    func stopCapture() {
        guard let captureSession = captureSession, captureSession.isRunning else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
            print("Camera capture session stopped")
        }
    }
    
    func pauseCapture() {
        stopCapture()
        shouldResumeOnAppear = true
    }
    
    func resumeCapture() {
        if shouldResumeOnAppear {
            startCapture()
            shouldResumeOnAppear = false
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            
            DispatchQueue.main.async { [weak self] in
                self?.scannedBarcode = stringValue
                self?.pauseCapture()
                print("Scanned barcode: \(stringValue)")
            }
        }
    }
    
    func toggleTorch() {
        guard let device = device, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == .on {
                device.torchMode = .off
                isTorchOn = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                isTorchOn = true
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error.localizedDescription)")
        }
    }
    
    func resetScan() {
        scannedBarcode = nil
    }
    
    deinit {
        stopCapture()
        print("BarcodeScannerViewModel deinitializing - camera resources released")
    }
}
