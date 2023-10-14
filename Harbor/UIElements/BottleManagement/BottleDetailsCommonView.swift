//
//  BottleDetailsCommonView.swift
//  Harbor
//
//  Created by Venti on 13/10/2023.
//

import SwiftUI

struct SyncPrimitivesSelector: View {
    @Binding var bottle: HarborBottle

    var body: some View {
        Group {
            HStack {
                Text("sheet.advConf.SyncPrimitives")
                Spacer()
                Menu {
                    Button("sheet.advConf.SyncPrimitives.none") {
                        bottle.syncPrimitives = .none
                    }
                    Button(WineSyncronizationPrimatives.eSync.rawValue) {
                        bottle.syncPrimitives = .eSync
                    }
                    Button(WineSyncronizationPrimatives.mSync.rawValue) {
                        bottle.syncPrimitives = .mSync
                    }
                } label: {
                    Text(bottle.syncPrimitives.rawValue)
                }
                .frame(maxWidth: 100)
            }
        }
    }
}

struct DXVKToggle: View {
    @Binding var bottle: HarborBottle
    @State var canSetDX = false
    @State var bottleDXBackend: DXBackend = .how
    var body: some View {
        Group {
            if canSetDX {
                // Dropdown to select DX backend
                // Picker("sheet.advConf.DXBackend", selection: $bottleDXBackend) {
                //     Text(DXBackend.gptk.rawValue).tag(DXBackend.gptk)
                //     Text(DXBackend.dxvk.rawValue).tag(DXBackend.dxvk)
                //         .disabled(!DXUtils.shared.isDXVKAvailable())
                //     Text(DXBackend.wined3d.rawValue).tag(DXBackend.wined3d)
                //         .disabled(!DXUtils.shared.isWineD3DAvailable())
                // }
                HStack {
                    Text("sheet.advConf.DXBackend")
                    Spacer()
                    Menu {
                        Button(DXBackend.gptk.rawValue) {
                            bottleDXBackend = .gptk
                        }
                        Button(DXBackend.dxvk.rawValue) {
                            bottleDXBackend = .dxvk
                        }
                        .disabled(!DXUtils.shared.isDXVKAvailable())
                        Button(DXBackend.wined3d.rawValue) {
                            bottleDXBackend = .wined3d
                        }
                        .disabled(!DXUtils.shared.isWineD3DAvailable())
                    } label: {
                        Text(bottleDXBackend.rawValue)
                    }
                    .disabled(!canSetDX)
                    // Limit the length (else it looks stupid)
                    .frame(maxWidth: 100)
                }
                .onChange(of: bottleDXBackend) { _, newValue in
                    canSetDX = false
                    Task.detached {
                        BottleDX.shared.updateDXBackend(for: bottle, using: newValue)
                        Task { @MainActor in
                            canSetDX = true
                        }
                    }
                }
            } else {
                HStack {
                    Text("sheet.advConf.dxvkToggle")
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
            }
        }
        .onAppear {
            Task.detached {
                bottleDXBackend = BottleDX.shared.checkBottleBackend(for: bottle)
                Task { @MainActor in
                    canSetDX = true
                }
            }
        }
    }
}

struct RetinaModeToggle: View {
    @Binding var bottle: HarborBottle
    @State var canSetRetinaMode = false
    @State var bottleRetinaMode = false

    var body: some View {
        Group {
            if canSetRetinaMode {
                Toggle("sheet.advConf.retinaToggle", isOn: $bottleRetinaMode)
                    .disabled(!canSetRetinaMode)
                    .onChange(of: bottleRetinaMode) { _, newValue in
                        canSetRetinaMode = false
                        Task.detached {
                            setRetinaMode(newValue)
                            Task { @MainActor in
                                canSetRetinaMode = true
                            }
                        }
                    }
            } else {
                HStack {
                    Text("sheet.advConf.retinaToggle")
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
            }
        }
        .onAppear {
            Task.detached(priority: .background) {
                bottleRetinaMode = queryRetinaMode()
                Task { @MainActor in
                    canSetRetinaMode = true
                }
            }
        }
    }
    func queryRetinaMode() -> Bool {
        let result = bottle.directLaunchApplication("reg.exe", arguments: ["query", #"HKCU\Software\Wine\Mac Driver"#,
                                                                            "-v", "RetinaMode"])
        if let result = result.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").last {
            return result == "y"
        } else {
            return false
        }
    }
    func setRetinaMode(_ value: Bool) {
        if value {
            bottle.directLaunchApplication("reg.exe", arguments:
                                            ["add", #"HKCU\Software\Wine\Mac Driver"#,
                                             "/v", "RetinaMode",
                                             "/d", "y", "/f"])
        } else {
            bottle.directLaunchApplication("reg.exe", arguments:
                                            ["delete",
                                             #"HKCU\Software\Wine\Mac Driver"#,
                                             "/v", "RetinaMode", "/f"])
        }
    }
}
