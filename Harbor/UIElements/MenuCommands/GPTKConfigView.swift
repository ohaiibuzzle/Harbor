//
//  ReinstallGPTKView.swift
//  Harbor
//
//  Created by Venti on 01/07/2023.
//

import SwiftUI

struct GPTKConfigView: View {
    @Binding var isPresented: Bool
    @State var gpkSelected = false
    @Environment(\.gpkUtils) var gpkUtils

    var body: some View {
        VStack {
            Text("sheet.GPTKConfig.title")
                .font(.title)
                .padding()

            Text("sheet.GPTKConfig.subtitle")
                .multilineTextAlignment(.center)

            VStack(alignment: .center) {
                HStack {
                    Button("btn.browse") {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = true
                        panel.canChooseDirectories = false
                        panel.allowsMultipleSelection = false
                        panel.allowedContentTypes = [.diskImage]
                        panel.begin { response in
                            if response == .OK {
                                let result = panel.url
                                if let result = result {
                                    let destination = HarborUtils.shared.getContainerHome()
                                        .appendingPathComponent("GPK.dmg")
                                    do {
                                        // Remove any existing GPK.dmg
                                        if FileManager.default.fileExists(atPath: destination.path) {
                                            try FileManager.default.removeItem(at: destination)
                                        }
                                        try FileManager.default.copyItem(at: result, to: destination)
                                        gpkSelected = true
                                    } catch {
                                        NSLog("sheet.GPKInstall.status.failedCopy \(destination)")
                                    }
                                }
                            }
                        }
                    }
                    if gpkSelected {
                        Text("sheet.GPKInstall.status.selected")
                            .foregroundColor(.green)
                    }
                }
                .padding()

                Button("sheet.GPTKConfig.updateGPTKLibs") {
                    gpkUtils.reinstallGPKLibraries()
                    isPresented.toggle()
                }
                .disabled(!gpkSelected)

                Button("sheet.GPTKConfig.removeGPTK") {
                    let alert = NSAlert()
                    alert.messageText = String(localized: "sheet.GPTKConfig.removeGPTK.title")
                    alert.informativeText = String(localized: "sheet.GPTKConfig.removeGPTK.subtitle")
                    alert.addButton(withTitle: String(localized: "home.btn.nuke"))
                    alert.addButton(withTitle: String(localized: "btn.cancel"))
                    alert.alertStyle = .warning
                    alert.runModal() == .alertFirstButtonReturn ? {
                        Task.detached {
                            gpkUtils.completelyRemoveGPK()
                            Task { @MainActor in
                                isPresented.toggle()
                            }
                        }
                    }() : ()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding()
            Button("btn.OK") {
                isPresented.toggle()
            }
        }
        .padding()
    }
}

struct GPTKConfigView_Previews: PreviewProvider {
    static var previews: some View {
        GPTKConfigView(isPresented: Binding.constant(true))
            .environment(\.brewUtils, .init())
            .environment(\.gpkUtils, .init())
    }
}
