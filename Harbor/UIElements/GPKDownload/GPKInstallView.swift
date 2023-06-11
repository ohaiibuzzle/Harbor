//
//  GPKDownloadView.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import SwiftUI

struct GPKDownloadView: View {
    @Binding var isPresented: Bool
    @State var gpkSelected = false
    @State var gpkInstalling = false
    
    @Binding var gpkInstalled: Bool
    
    var body: some View {
        VStack {
            Text("sheet.GPKInstall.title")
                .bold()
                .font(.title)
                .padding()
            Text("sheet.GPKInstall.subTitle")
            .multilineTextAlignment(.center)
            .padding()
            if GPKUtils.shared.checkGPKInstallStatus() == .installed {
                Text("sheet.GPKInstall.status.installed")
                    .foregroundColor(.green)
                    .padding()
            } else {
                VStack {
                    HStack {
                        Button(action: {
                            NSWorkspace.shared.open(URL(
                                string: "https://developer.apple.com/download/more/?=game%20porting%20toolkit")!)
                        }) {
                            Text("sheet.GPKInstall.btn.download")
                        }
                        // Browse button for GPK
                        Button("btn.browse") {
                            let panel = NSOpenPanel()
                            panel.canChooseFiles = true
                            panel.canChooseDirectories = false
                            panel.allowsMultipleSelection = false
                            panel.allowedFileTypes = ["dmg"]
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
                    }
                    if gpkSelected {
                        Text("sheet.GPKInstall.status.selected")
                            .foregroundColor(.green)
                    }
                }
                .padding()
            }
            HStack {
                Button("btn.cancel") {
                    isPresented = false
                }
                
                if GPKUtils.shared.checkGPKInstallStatus() != .installed {
                    Button(action: {
                        if GPKUtils.shared.showGPKInstallAlert() {
                            gpkInstalling = true
                            Task.detached(priority: .userInitiated) {
                                GPKUtils.shared.installGPK()
                                Task { @MainActor in
                                    gpkInstalling = false
                                    gpkInstalled = GPKUtils.shared.checkGPKInstallStatus() == .installed
                                }
                            }
                        }
                    }) {
                        Text("sheet.GPKInstall.btn.install")
                    }
                    .disabled(gpkSelected == false)
                } else {
                    Button(action: {
                        isPresented = false
                        gpkInstalled = true
                    }) {
                        Text("btn.OK")
                    }
                }
            }
        }
        .padding()
    }
}

struct GPKDownloadView_Previews: PreviewProvider {
    static var previews: some View {
        GPKDownloadView(isPresented: Binding.constant(true), gpkInstalled: Binding.constant(false))
    }
}
