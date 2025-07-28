//
//  BarcodeScannerView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
//
import SwiftUI
import AVFoundation
import UIKit
import Firebase
import FirebaseFirestore

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BarcodeScannerViewModel()
    @State private var navigateToHome = false
    @State private var showProductAnalysis = false
    @State private var glow = false
    
    @Binding var selectedTab: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScannerUIView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    ScannerOverlayView()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        if let barcode = viewModel.scannedBarcode {
                            scanResultView(barcode: barcode)
                        } else {
                            instructionsView
                        }
                        
                        Button(action: {
                            viewModel.toggleTorch()
                        }) {
                            HStack {
                                Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                    .font(.system(size: 20))
                                Text(viewModel.isTorchOn ? "Turn Off Flashlight" : "Turn On Flashlight")
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 450)
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.startCapture()
            }
            .onDisappear {
                viewModel.stopCapture()
            }
            .alert(isPresented: $viewModel.showPermissionAlert) {
                Alert(
                    title: Text("Camera Permission Required"),
                    message: Text("Please allow camera access in Settings to scan barcodes."),
                    primaryButton: .default(Text("Open Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func scanResultView(barcode: String) -> some View {
        VStack(spacing: 15) {
            Text("Barcode Detected")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(barcode)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(Color.blue.opacity(0.7))
                .cornerRadius(8)
            
            HStack(spacing: 15) {
                Button(action: {
                    viewModel.resetScan()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Scan Again")
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.pauseCapture()
                    showProductAnalysis = true
                }) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                        Text("Analyze")
                    }
                    .padding()
                    .background(Color.green.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: Color.green.opacity(3.0), radius: glow ? 30 : 10)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            glow.toggle() }
                    }
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
        .onAppear {
            viewModel.pauseCapture()
        }
        .fullScreenCover(isPresented: $showProductAnalysis, onDismiss: {
            viewModel.resumeCapture()
        }) {
            ProductAnalysisView(barcode: barcode)
        }
    }
    
    private var instructionsView: some View {
        VStack {
            Text("Position the barcode in the frame")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            Text("Scanning will happen automatically")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(10)
    }
}



