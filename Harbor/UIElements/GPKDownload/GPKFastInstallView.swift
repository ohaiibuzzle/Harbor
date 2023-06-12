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
    @Environment(\.brewUitls)
    var brewUtils

    var body: some View {
        VStack {
            Text("sheet.GPKInstall.title")
                .bold()
                .font(.title)
                .padding()
            Text("sheet.fastGPKInstall.subtitle")
                .multilineTextAlignment(.center)
                .padding()

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
                                panel.allowedFileTypes = ["gz"]
                                panel.begin { response in
                                    if response == .OK {
                                        let result = panel.url
                                        if let result = result {
                                            gpkPath = result
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
                        GridRow {
                            Button {
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
                    }
                    .padding()

                    HStack {
                        Button("btn.cancel") {
                            isPresented = false
                        }

                        if gpkUtils.status != .installed {
                            Button(action: {
                                if let gpkConcretePath = gpkPath {
                                    gpkInstalling = true
                                    Task.detached(priority: .userInitiated) {
                                        gpkUtils.fastInstallGPK(using: brewUtils, gpkBottle: gpkConcretePath)
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
            }
        }
        .padding()
    }
}

#Preview {
    GPKFastInstallView(isPresented: Binding.constant(true))
}
