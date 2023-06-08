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
            Text("Install Apple's Game Porting Toolkit")
                .bold()
                .font(.title)
                .padding()
            Text("""
                 In order to function, Harbor needs a copy of Apple's Game Porting Toolkit.
                 You can download it from Apple Developers as we can't include it due to Apple's license
                 """)
            .multilineTextAlignment(.center)
            .padding()
            if GPKUtils.shared.checkGPKInstallStatus() == .installed {
                Text("GPK is already installed")
                    .foregroundColor(.green)
                    .padding()
            } else {
                VStack {
                    // Browse button for GPK
                    Button("Browse") {
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
                                        NSLog("Failed to copy GPK.dmg to \(destination)")
                                    }
                                }
                            }
                        }
                    }
                    if gpkSelected {
                        Text("GPK.dmg selected")
                            .foregroundColor(.green)
                    }
                }
                .padding()
            }
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Button(action: {
                    NSWorkspace.shared.open(URL(
                        string: "https://developer.apple.com/download/more/?=game%20porting%20toolkit")!)
                }) {
                    Text("Download GPK")
                }
                if GPKUtils.shared.checkGPKInstallStatus() != .installed {
                    Button(action: {
                        if GPKUtils.shared.showGPKInstallAlert() {
                            gpkInstalling = true
                            Task.detached(priority: .userInitiated) {
                                GPKUtils.shared.installGPK()
                                Task { @MainActor in
                                    gpkInstalling = false
                                }
                            }
                        }
                    }) {
                        Text("Install GPK")
                    }
                    .disabled(gpkSelected == false)
                } else {
                    Button(action: {
                        isPresented = false
                        gpkInstalled = true
                    }) {
                        Text("Done")
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
