//
//  ContentView.swift
//  SAMMARTINSStickerMaker
//
//  Created by Silvanei  Martins on 23/05/24.
//

import SwiftUI

struct ContentView: View {
    
    let columns = [GridItem(.adaptive(minimum: width, maximum: width), spacing: spacing)]
    @State var vm = ViewModel()
    
    var body: some View {
        ScrollView {
            HStack {
                ImagePicker {
                    ImageContainerView(badgeText: "IC", image: vm.showOriginalImage ? vm.trayIcon.inputImage : vm.trayIcon.outputImage)
                } onSelectedImage: { image in
                    vm.onInputImageSelected(image, sticker: vm.trayIcon)
                }
                
                Toggle("Montrar Original", isOn: $vm.showOriginalImage)
            }
            .padding(32)
            
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(vm.stickers) {sticker in
                    ImagePicker {
                        ImageContainerView(badgeText: String(sticker.pos + 1), image: vm.showOriginalImage ? sticker.inputImage : sticker.outputImage)
                    } onSelectedImage: { image in
                        vm.onInputImageSelected(image, sticker: sticker)
                    }
                }
            }
        }
        .navigationTitle("Martins Sticker")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Exportar") {
                    vm.sendToWhatsApp()
                }
                .disabled(!vm.isAbleToExportAsStickers)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
