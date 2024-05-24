//
//  ImagePicker.swift
//  SAMMARTINSStickerMaker
//
//  Created by Silvanei  Martins on 23/05/24.
//

import UIKit
import SwiftUI
import PhotosUI
import CoreImage.CIImage

struct ImagePicker<Label>: View where Label: View {
    
    @State private var imageSelection: PhotosPickerItem? = nil
    
    var label: () -> Label
    let onSelectedImage: (CIImage) -> ()
    
    var body: some View {
        PhotosPicker(selection: $imageSelection, matching: .images) {
            label()
        }
        .onChange(of: imageSelection) {_, newSelection in
            self.loadInputImage(fromPhotpsPickerItem: newSelection)
        }
    }
    
    private func loadInputImage(fromPhotpsPickerItem item: PhotosPickerItem?) {
        guard let item else { return }
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .failure(let error):
                print("Failed to load: \(error)")
                return
            case .success(let _data):
                guard let data = _data else {
                    print("Failed to load image data")
                    return
                }
                
                guard var image = CIImage(data: data) else {
                    print("Failed to create image from selected phot")
                    return
                }
                
                if let orientation = image.properties["Orientation"] as? Int32, orientation != 1 {
                    image = image.oriented(forExifOrientation: orientation)
                }
                
                DispatchQueue.main.async {
                    onSelectedImage(image)
                }
            }
        }
    }
}

#Preview {
    ImagePicker {
        Text("Selecione uma Imagem")
    } onSelectedImage: { image in
        
    }
}
