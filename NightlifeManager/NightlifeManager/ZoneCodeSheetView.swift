//
//  ZoneCodeSheetView.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import SwiftUI
import AppKit
import CoreImage.CIFilterBuiltins
import SharedKit

/// Printable QR codes of every zone, labelled with floor and zone name (L7, K16).
struct ZoneCodeSheetView: View {
    @ObservedObject var viewModel: VenueDesignerViewModel

    var body: some View {
        Group {
            if viewModel.zoneCodes.isEmpty {
                ContentUnavailableView("Még nincs zóna",
                                       systemImage: "qrcode",
                                       description: Text("Rajzolj zónákat a helyszíntervezőben."))
            } else {
                ScrollView {
                    CodeGrid(codes: viewModel.zoneCodes).padding()
                }
            }
        }
        .navigationTitle("Zónakódok")
        .toolbar {
            Button("Nyomtatás", systemImage: "printer", action: printSheet)
                .disabled(viewModel.zoneCodes.isEmpty)
        }
    }

    private func printSheet() {
        let rows = (viewModel.zoneCodes.count + 2) / 3
        let view = NSHostingView(rootView: CodeGrid(codes: viewModel.zoneCodes).padding().background(.white))
        view.frame = CGRect(x: 0, y: 0, width: 595, height: CGFloat(rows) * 220 + 40)
        NSPrintOperation(view: view).run()
    }
}

private struct CodeGrid: View {
    let codes: [ZoneCode]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 24) {
            ForEach(codes, id: \.payload) { code in
                VStack {
                    if let image = QRCodeImage.make(from: code.payload) {
                        Image(nsImage: image)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 140, height: 140)
                    }
                    Text(code.label).font(.headline)
                }
            }
        }
    }
}

enum QRCodeImage {
    static func make(from text: String) -> NSImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)) else { return nil }
        let representation = NSCIImageRep(ciImage: output)
        let image = NSImage(size: representation.size)
        image.addRepresentation(representation)
        return image
    }
}
