//
//  BottleConfigDropdown.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct BottleConfigDropdown: View {
    @Binding var isPresented: Bool
    @Binding var bottle: HarborBottle

    @State var canSetDXVK = false
    @State var bottleDXVKStatus = false

    var body: some View {
        VStack {
            Text("sheet.advConf.title \(bottle.name)")
                .font(.title)
                .padding()
            Spacer()
            VStack(alignment: .leading) {
                Toggle("sheet.advConf.hudToggle", isOn: $bottle.enableHUD)
                Toggle("sheet.advConf.eSyncToggle", isOn: $bottle.enableESync)
                Toggle("sheet.advConf.stdOutToggle", isOn: $bottle.pleaseShutUp)
                if canSetDXVK {
                    Toggle("sheet.advConf.dxvkToggle", isOn: $bottleDXVKStatus)
                        .disabled(!DXVKUtils.shared.isDXVKAvailable() || !canSetDXVK)
                        .onChange(of: bottleDXVKStatus) { _, newValue in
                            canSetDXVK = false
                            Task.detached {
                                if newValue {
                                    BottleDXVK.shared.installDXVKToBottle(bottle: bottle)
                                } else {
                                    BottleDXVK.shared.removeDXVKFromBottle(bottle: bottle)
                                }
                                Task { @MainActor in
                                    canSetDXVK = true
                                }
                            }
                        }
                } else {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                        Text("sheet.advConf.dxvkToggle")
                    }
                }
            }
            Spacer()
            HStack {
                Button("sheet.advConf.winecfgBtn") {
                    bottle.launchApplication("winecfg")
                }
                Button("sheet.advConf.explorerBtn") {
                    bottle.launchApplication("explorer")
                }
                Button("sheet.advConf.regeditBtn") {
                    bottle.launchApplication("regedit")
                }
            }
            Spacer()
            Button("btn.OK") {
                if let bottleIndex = BottleLoader.shared.bottles.firstIndex(where: { $0.id == bottle.id }) {
                    BottleLoader.shared.bottles[bottleIndex] = bottle
                }
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
        }
        .frame(minWidth: 300, minHeight: 300)
        .padding()
        .onAppear {
            Task.detached {
                bottleDXVKStatus = BottleDXVK.shared.checkBottleForDXVK(bottle: bottle)
                Task { @MainActor in
                    canSetDXVK = true
                }
            }
        }
    }
}

struct BottleConfigDropdown_Previews: PreviewProvider {
    static var previews: some View {
        BottleConfigDropdown(isPresented: Binding.constant(true),
                             bottle: Binding.constant(HarborBottle(
                                id: UUID(), name: "Bottle", path: URL(fileURLWithPath: ""))))
        .environment(\.brewUtils, .init())
    }
}
