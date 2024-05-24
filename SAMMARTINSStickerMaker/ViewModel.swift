//
//  ViewModel.swift
//  SAMMARTINSStickerMaker
//
//  Created by Silvanei  Martins on 23/05/24.
//

import Foundation
import Observation
import SwiftUI
import CoreImage
import UIKit
import SwiftWebP

@Observable
class ViewModel {
    
    private static let PasteboardStickerPackDataType = "net.whatsapp.third-party.sticker-pack"
    private static let whatsAPPURL = URL(string: "whatsapp://stickerPack")!
    private static let PasteboardExpirationSeconds: TimeInterval = 60
    
    var trayIcon = Sticker(isTrayIcon: true)
    var stickers: [Sticker] = (0...29).map {i in Sticker(pos: i) }
    
    var showOriginalImage = false
    var imageHelper = ImageVisionHelper()
    
    var isAbleToExportAsStickers: Bool {
        let stickersCount = self.stickers.filter { $0.outputImage != nil }.count
        return stickersCount > 2 && trayIcon.outputImage != nil
    }
    
    func onInputImageSelected(_ image: CIImage, sticker: Sticker) {
        let inputCIImage = image
        let inputImage = UIImage(cgImage: imageHelper.render(ciImage: inputCIImage))
        let outputImage = self.removeImageBackground(input: inputCIImage)
        var sticker = sticker
        
        let imageData = ImageData(inputCIImage: inputCIImage, inputImage: inputImage, outputImage: outputImage)
        sticker.state = .seleted(imageData)
        
        if sticker.isTrayIcon {
            trayIcon = sticker
        } else {
            stickers[sticker.pos] = sticker
        }
    }
    
    func removeImageBackground(input: CIImage) -> UIImage? {
        guard let maskedImage = imageHelper.removeBackground(from: input, croppedToInstanceExtent: true) else {
            return nil
        }
        
        return UIImage(cgImage: imageHelper.render(ciImage: maskedImage))
    }
    
    func sendToWhatsApp() {
        guard isAbleToExportAsStickers,
          let trayOutputImage = trayIcon.imageData?.outputImage
        else { return }
        
        let outputImageTrayData = trayOutputImage.scaleToFit(targetSize: .init(width: 96, height: 96)).scaledPNGData()
        
        print("Tamanho em bytes da bandeja \(outputImageTrayData.count)")
        
        var json: [String: Any] = [:]
        json["identifier"] = "samID"
        json["name"] = "Martins"
        json["publisher"] = "Silvanei Martins"
        json["tray_image"] = outputImageTrayData.base64EncodedString()
        
        var stickersArray: [[String: Any]] = []
        let stickersImage = self.stickers.compactMap { $0.imageData?.outputImage }
        
        for image in stickersImage {
            var stickersDict = [String: Any]()
            let outputPngData = image.scaleToFit(targetSize: .init(width: 512, height: 512)).scaledPNGData()
            
            print("Tamanho da figurinha \(outputPngData.count)")
            
            if let imageData = WebPEncoder().encodePNG(data: outputPngData) {
                stickersDict["image_data"] = imageData.base64EncodedString()
                stickersDict["emojis"] = ["🤣"]
                stickersArray.append(stickersDict)
            }
        }
        json["stickers"] = stickersArray
        
        var jsonWithAppStoreLink: [String: Any] = json
        jsonWithAppStoreLink["ios_app_store_link"] = ""
        jsonWithAppStoreLink["android_play_store_link"] = ""
        
        guard let dataToSend = try? JSONSerialization.data(withJSONObject: jsonWithAppStoreLink, options: []) else {
            return
        }
        
        let pasteboard = UIPasteboard.general
        pasteboard.setItems([[ViewModel.PasteboardStickerPackDataType: dataToSend]], options: [
            UIPasteboard.OptionsKey.localOnly: true,
            UIPasteboard.OptionsKey.expirationDate: Date(timeIntervalSinceNow: ViewModel.PasteboardExpirationSeconds)
        ])
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!) {
                UIApplication.shared.open(ViewModel.whatsAPPURL)
            }
        }
    }
}
