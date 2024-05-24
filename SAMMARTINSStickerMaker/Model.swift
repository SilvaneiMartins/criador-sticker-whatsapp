//
//  Model.swift
//  SAMMARTINSStickerMaker
//
//  Created by Silvanei  Martins on 23/05/24.
//

import Foundation
import CoreImage
import UIKit
import SwiftUI


enum StickerState {
    case none
    case seleted(ImageData)
}

struct ImageData {
    var inputCIImage: CIImage?
    var inputImage: UIImage
    var outputImage: UIImage?
}

struct Sticker: Identifiable {
    
    let id = UUID()
    var pos: Int = 0
    var state = StickerState.none
    var isTrayIcon = false
    
    var imageData: ImageData? {
        if case let .seleted(imageData) = state {
            return imageData
        }
        
        return nil
    }
    
    var inputImage: Image? {
        guard let imageData else { return nil }
        return Image(uiImage: imageData.inputImage)
    }
    
    var outputImage: Image? {
        guard let imageData, let outputImage = imageData.outputImage else { return nil }
        return Image(uiImage: outputImage)
    }
}
