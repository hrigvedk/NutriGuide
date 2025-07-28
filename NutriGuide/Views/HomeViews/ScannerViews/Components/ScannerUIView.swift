//
//  ScannerUIView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI

struct ScannerUIView: UIViewRepresentable {
    @ObservedObject var viewModel: BarcodeScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        viewModel.setupCaptureSession(view: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
