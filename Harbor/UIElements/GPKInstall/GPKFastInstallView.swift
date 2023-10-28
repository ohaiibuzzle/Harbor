//
//  GPKFastInstallView.swift
//  Harbor
//
//  Created by Venti on 12/06/2023.
//

import SwiftUI

struct GPKFastInstallView: View {
    @Binding var isPresented: Bool

    @State var gpkSelected = false
    @State var gpkInstalling = false
    @State var gpkPath: URL?

    @Environment(\.gpkUtils)
    var gpkUtils
    @Environment(\.brewUtils)
    var brewUtils

    @State var isUsingNewArchive = false

    var body: some View {
        VStack {
            Text("sheet.GPKInstall.title")
                .bold()
                .font(.title)
                .padding()
            Text("sheet.fastGPKInstall.subtitle")
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
                        Button {
                            if let url = URL(string:
                                "https://github.com/ohaiibuzzle/HarborBuilder/actions/workflows/1.build-gptk.yml") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Text("HarborBuilder")
                                .frame(minWidth: 200)
                        }
                        Text("")
                    }
                    Grid {
                        GridRow {
                            Button {
                                let panel = NSOpenPanel()
                                panel.canChooseFiles = true
                                panel.canChooseDirectories = false
                                panel.allowsMultipleSelection = false
                                panel.allowedContentTypes = [.gzip]
                                panel.begin { response in
                                    if response == .OK {
                                        let result = panel.url
                                        if let result = result {
                                            gpkPath = result
                                            if checkForNewBuilderFormat(for: result) {
                                                isUsingNewArchive = true
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text("sheet.fastGPKInstall.btn.selectBottle")
                                    .frame(minWidth: 200)
                            }
                            if let gpkPath = gpkPath {
                                Text(gpkPath.lastPathComponent)
                            } else {
                                Text("")
                            }
                        }
                        if !isUsingNewArchive {
                            GridRow {
                                Button {
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
                                } label: {
                                    Text("sheet.GPKInstall.btn.selectGPK")
                                        .frame(minWidth: 200)
                                }
                                if gpkSelected {
                                    Text("sheet.GPKInstall.status.selected")
                                        .foregroundColor(.green)
                                } else {
                                    Text("")
                                }
                            }
                        } else {
                            Text("sheet.fastGPKInstall.fastArchiveDetected")
                        }
                    }
                    .padding()
                    Spacer()
                    HStack {
                        Button("btn.cancel") {
                            isPresented = false
                        }

                        if gpkUtils.status != .installed {
                            Button(action: {
                                if let gpkConcretePath = gpkPath {
                                    gpkInstalling = true
                                    Task.detached(priority: .userInitiated) {
                                        gpkUtils.fastInstallGPK(using: brewUtils,
                                                                gpkBottle: gpkConcretePath,
                                                                bundledGPK: isUsingNewArchive)
                                        Task { @MainActor in
                                            gpkInstalling = false
                                            gpkUtils.checkGPKInstallStatus()
                                        }
                                    }
                                }
                            }, label: {
                                Text("sheet.GPKInstall.btn.install")
                            })
                            .disabled(!gpkSelected && !isUsingNewArchive)
                        } else {
                            Button(action: {
                                isPresented = false
                            }, label: {
                                Text("btn.OK")
                            })
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minHeight: 300)
    }

    // Function to check if the new Builder format (incl. gptk) is being used
    // Input would be a file url
    func checkForNewBuilderFormat(for path: URL) -> Bool {
        let upperDir = path.deletingLastPathComponent()
        // Look for gptk_libs
        let gptkLibs = upperDir.appendingPathComponent("gptk_libs")
        if FileManager.default.fileExists(atPath: gptkLibs.path) {
            return true
        }
        return false
    }
}

struct GPKFastInstallView_Previews: PreviewProvider {
    static var previews: some View {
        GPKFastInstallView(isPresented: Binding.constant(true))
            .environment(\.gpkUtils, .init())
            .environment(\.brewUtils, .init())
    }
}
