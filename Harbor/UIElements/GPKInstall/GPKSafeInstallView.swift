//
//  GPKDownloadView.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import SwiftUI

struct GPKSafeInstallView: View {
    @Binding var isPresented: Bool
    @State var gpkSelected = false
    @State var gpkInstalling = false

    @Environment(\.gpkUtils)
    var gpkUtils
    @Environment(\.brewUtils)
    var brewUtils

    var body: some View {
        VStack {
            Text("sheet.GPKInstall.title")
                .bold()
                .font(.title)
                .padding()
            Text("sheet.GPKInstall.subTitle")
            .multilineTextAlignment(.center)
            .font(.subheadline)
            .padding()
            Spacer()
            if gpkUtils.status == .installed {
                Text("sheet.GPKInstall.status.installed")
                    .foregroundColor(.green)
                    .padding()
            } else {
                VStack {
                    HStack {
                        Button(action: {
                            if let url = URL(
                                string: "https://developer.apple.com/download/more/?=game%20porting%20toolkit") {
                                NSWorkspace.shared.open(url)
                            }
                        }, label: {
                            Text("sheet.GPKInstall.btn.download")
                        })
                        // Browse button for GPK
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
                    }
                    if gpkSelected {
                        Text("sheet.GPKInstall.status.selected")
                            .foregroundColor(.green)
                    }
                }
                .padding()
            }
            Spacer()
            HStack {
                Button("btn.cancel") {
                    isPresented = false
                }

                if gpkUtils.status != .installed {
                    Button(action: {
                        if gpkUtils.showGPKInstallAlert() {
                            gpkInstalling = true
                            Task.detached(priority: .userInitiated) {
                                gpkUtils.installGPK(using: brewUtils)
                                Task { @MainActor in
                                    gpkInstalling = false
                                    gpkUtils.checkGPKInstallStatus()
                                }
                            }
                        }
                    }, label: {
                        Text("sheet.GPKInstall.btn.install")
                    })
                    .disabled(gpkSelected == false)
                } else {
                    Button(action: {
                        isPresented = false
                    }, label: {
                        Text("btn.OK")
                    })
                }
            }
        }
        .padding()
        .frame(minHeight: 300)
    }
}

struct GPKSafeInstallView_Previews: PreviewProvider {
    static var previews: some View {
        GPKSafeInstallView(isPresented: Binding.constant(true))
            .environment(\.gpkUtils, .init())
            .environment(\.brewUtils, .init())
    }
}
