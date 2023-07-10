//
//  MeView.swift
//  HotProspects
//
//  Created by Alex Scherbakov on 4/13/23.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

// MARK: - MeView

struct MeView: View {
    @State private var name = "Anonymous"
    @State private var emailAddress = "you@yoursite.com"
    @State private var qrCode = UIImage()

    var payload: String {
        "\(name)\n\(emailAddress)"
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)

                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)

                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
            }
            .navigationTitle("Your QR")
            .onAppear { generateQRCode(from: payload) }
            .onChange(of: payload, perform: generateQRCode)
        }
    }

    // MARK: Internal

    func generateQRCode(from string: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImg = context.createCGImage(outputImage, from: outputImage.extent) {
                qrCode = UIImage(cgImage: cgImg)
                return
            }
        }

        qrCode = UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

// MARK: - MeView_Previews

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
