//
//  CodeReaderView.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import SwiftUI
import VisionKit

/// Camera code reader for tickets and zone codes (K7). Verified manually on a device.
struct CodeReaderView: View {
    @ObservedObject var viewModel: CodeReaderViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                BarcodeScanner { payload in
                    viewModel.handle(payload: payload)
                }
                .ignoresSafeArea()
            } else {
                ContentUnavailableView("A kódolvasó nem érhető el",
                                       systemImage: "barcode.viewfinder",
                                       description: Text("Ezen az eszközön nincs kamera, vagy nincs engedélyezve a használata."))
            }

            if let message = viewModel.message {
                Text(message)
                    .font(.headline)
                    .padding()
                    .background(.regularMaterial, in: Capsule())
                    .padding(.bottom, 32)
            }
        }
        .navigationTitle("Kódolvasó")
    }
}

/// Wraps VisionKit's scanner and reports each newly recognised 1D/2D code once.
private struct BarcodeScanner: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(recognizedDataTypes: [.barcode()],
                                                qualityLevel: .balanced,
                                                recognizesMultipleItems: false,
                                                isHighFrameRateTrackingEnabled: false,
                                                isHighlightingEnabled: true)
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        if !scanner.isScanning {
            try? scanner.startScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCode: onCode)
    }

    @MainActor
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onCode: (String) -> Void
        private var lastPayload: String?

        init(onCode: @escaping (String) -> Void) {
            self.onCode = onCode
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            for case .barcode(let barcode) in addedItems {
                guard let payload = barcode.payloadStringValue, payload != lastPayload else { continue }
                lastPayload = payload
                onCode(payload)
            }
        }
    }
}
