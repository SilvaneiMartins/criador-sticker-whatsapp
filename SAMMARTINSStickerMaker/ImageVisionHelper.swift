//
//  ImageVisionHelper.swift
//  SAMMARTINSStickerMaker
//
//  Created by Silvanei  Martins on 23/05/24.
//

import Foundation
import CoreImage
import Vision

struct ImageVisionHelper {
    
    func render(ciImage img: CIImage) -> CGImage {
        guard let cgImage = CIContext(options: nil).createCGImage(img, from: img.extent) else {
            fatalError("Failed to render CIImage")
        }
        
        return cgImage
    }
    
    func removeBackground(from image: CIImage, croppedToInstanceExtent: Bool) -> CIImage? {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform vision request")
            return nil
        }
        
        guard let result = request.results?.first else {
            print("No subject observations found")
            return nil
        }
        
        do {
            let maskedImage = try result.generateMaskedImage(ofInstances: result.allInstances, from: handler, croppedToInstancesExtent: croppedToInstanceExtent)
            
            return CIImage(cvPixelBuffer: maskedImage)
        } catch {
            print("Failed to generate masked image")
            return nil
        }
    }
}
