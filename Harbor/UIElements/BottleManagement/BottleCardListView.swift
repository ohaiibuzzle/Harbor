//
//  VeryFancyBottleView.swift
//  Harbor
//
//  Created by Venti on 17/06/2023.
//

import SwiftUI

struct BottleCardListView: View {
    @Bindable var bottles: BottleList
    @Binding var isShowingDetails: Bool

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach($bottles.bottles) { bottle in
                    BottleCardView(bottle: bottle, isShowingDetails: $isShowingDetails)
                }
            }
            .padding()
        }
    }
}

struct BottleCardView: View {
    @Binding var bottle: HarborBottle
    @Binding var isShowingDetails: Bool

    @State var isBeingHoveredUpon = false
    @State var showLaunchExtDropdown = false
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(bottle.name)
                    .font(.headline)
                Text(bottle.path.prettyFileUrl)
                    .font(.subheadline)
                if let primaryApp = bottle.primaryApplicationPath.components(separatedBy: "\\").last {
                    Text(primaryApp)
                        .font(.subheadline)
                }
            }
            Spacer()
            Group {
                Group {
                    Button {
                        bottle.launchPrimaryApplication()
                    } label: {
                        Image(systemName: "play")
                    }
                    .buttonStyle(.borderless)
                    Button {
                        showLaunchExtDropdown.toggle()
                    } label: {
                        Image(systemName: "tray.and.arrow.down")
                    }
                    .buttonStyle(.borderless)
                    Button {
                        bottle.killBottle()
                    } label: {
                        Image(systemName: "stop")
                    }
                    .buttonStyle(.borderless)
                }
                .opacity(isBeingHoveredUpon ? 100 : 0)
                NavigationLink {
                    BottleCardDetailedView(bottle: $bottle, isShowingDetail: $isShowingDetails)
                } label: {
                    Image(systemName: "chevron.forward.circle.fill")
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
        .background(in: RoundedRectangle(cornerSize:
                                            CGSize(width: 20, height: 10)),
                    fillStyle: .init())
        .sheet(isPresented: $showLaunchExtDropdown) {
            LaunchExtDropdown(isPresented: $showLaunchExtDropdown, bottle: bottle)
        }
        .onHover(perform: { hovering in
            isBeingHoveredUpon = hovering
        })
        .onTapGesture(count: 2, perform: {
            bottle.launchPrimaryApplication()
        })
    }
}

struct BottleCardDetailedView: View {
    @Binding var bottle: HarborBottle
    @Binding var isShowingDetail: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var bottlePath = ""
    @State var bottleDXVKStatus: Bool = false
    @State var canSetDXVK = false

    let monospaceFont = Font.body.monospaced()

    var body: some View {
        ScrollView {
            VStack {
                Form {
                    Section {
                        TextField("sheet.new.bottleNameLabel", text: $bottle.name)
                    }
                    Section {
                        HStack {
                            Text("sheet.new.bottlePathLabel")
                            TextField("", text: $bottlePath)
                                .textFieldStyle(.plain)
                                .font(monospaceFont)
                                .disabled(true)
                                .onAppear {
                                    bottlePath = bottle.path.prettyFileUrl
                                }
                        }
                    }
                    Section {
                        Text("sheet.edit.primaryAppLabel")
                        HStack {
                            TextField("", text: $bottle.primaryApplicationPath)
                                .font(monospaceFont)
                            Button("btn.browse") {
                                let dialog = NSOpenPanel()
                                dialog.title = "sheet.edit.primaryApp.popup"
                                dialog.showsResizeIndicator = true
                                dialog.showsHiddenFiles = false
                                dialog.canChooseDirectories = false
                                dialog.canChooseFiles = true
                                dialog.canCreateDirectories = false
                                dialog.allowsMultipleSelection = false
                                dialog.directoryURL = bottle.path
                                if dialog.runModal() == NSApplication.ModalResponse.OK {
                                    if let result = dialog.url {
                                        bottle.primaryApplicationPath = bottle.pathFromUnixPath(result)
                                    }
                                } else {
                                    // User clicked on "Cancel"
                                    return
                                }
                            }
                        }
                    }
                    Section {
                        Text("sheet.edit.primaryAppArgsLabel")
                        TextField("", text: $bottle.primaryApplicationArgument)
                            .font(monospaceFont)
                    }
                    Section {
                        Text("sheet.edit.primaryAppWorkDirLabel")
                        HStack {
                            TextField("", text: $bottle.primaryApplicationWorkDir)
                                .font(monospaceFont)
                            Button("btn.Auto") {
                                // Path up to the executable
                                // Remove the executable name from the Windows path
                                let path = bottle.primaryApplicationPath
                                    .replacingOccurrences(of: "\\", with: "/")
                                    .components(separatedBy: "/")
                                    .dropLast()
                                    .joined(separator: "\\")
                                bottle.primaryApplicationWorkDir = path
                            }
                            Button("btn.browse") {
                                let dialog = NSOpenPanel()
                                dialog.title = "sheet.edit.primaryApp.popup"
                                dialog.showsResizeIndicator = true
                                dialog.showsHiddenFiles = false
                                dialog.canChooseDirectories = true
                                dialog.canChooseFiles = false
                                dialog.canCreateDirectories = true
                                dialog.allowsMultipleSelection = false
                                dialog.directoryURL = bottle.path
                                if dialog.runModal() == NSApplication.ModalResponse.OK {
                                    if let result = dialog.url {
                                        bottle.primaryApplicationWorkDir = bottle.pathFromUnixPath(result)
                                    }
                                } else {
                                    // User clicked on "Cancel"
                                    return
                                }
                            }
                        }
                    }
                    Section {
                        Text("sheet.edit.envVars")
                        EnvironmentVarsEditor(environmentVars: $bottle.envVars)
                    }
                }
                .formStyle(.grouped)
                Form {
                    Section {
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
                                Text("sheet.advConf.dxvkToggle")
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .controlSize(.small)
                            }
                        }
                    }
                    Section {
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
                    }
                }
                .formStyle(.grouped)
                HStack {
                    Spacer()
                    Button {
                        bottle.directLaunchApplication("wineboot", arguments: ["-u"])
                    } label: {
                        Label("sheet.advConf.update", systemImage: "arrow.clockwise")
                    }
                    Button {
                        // ALARM
                        let alert = NSAlert()
                        alert.messageText = String(localized: "home.alert.deleteTitle")
                        alert.alertStyle = .critical
                        let checkbox = NSButton(checkboxWithTitle:
                                                    String(format: String(localized: "home.alert.deletePath %@"),
                                                           bottle.path.prettyFileUrl), target: nil, action: nil)
                        checkbox.state = .on
                        alert.accessoryView = checkbox
                        alert.addButton(withTitle: String(localized: "btn.delete"))
                        alert.addButton(withTitle: String(localized: "btn.cancel"))
                        if alert.runModal() == .alertFirstButtonReturn {
                            // User clicked on "Delete"
                            BottleLoader.shared.delete(bottle, checkbox.state)
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            // User clicked on "Cancel"
                            return
                        }
                    } label: {
                        Label("home.btn.nuke", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .navigationTitle(bottle.name)
        .onAppear {
            isShowingDetail = true
            Task.detached {
                bottleDXVKStatus = BottleDXVK.shared.checkBottleForDXVK(bottle: bottle)
                Task { @MainActor in
                    canSetDXVK = true
                }
            }
        }
        .onDisappear {
            if let bottleIndex = BottleLoader.shared.bottles.firstIndex(where: { $0.id == bottle.id }) {
                BottleLoader.shared.bottles[bottleIndex] = bottle
            }
            isShowingDetail = false
        }
    }
}

struct BottleListCardView_Previews: PreviewProvider {
    static var previews: some View {
        BottleCardListView(bottles: BottleList(), isShowingDetails: Binding.constant(false))
            .environment(\.brewUtils, .init())
    }
}

struct BottleCardDetailedView_Previews: PreviewProvider {
    static var sampleBottle = HarborBottle(id: UUID(), name: "Demo",
                                           path: FileManager.default.urls(for: .documentDirectory,
                                                                          in: .userDomainMask).first ??
                                           URL(filePath: ""))
    static var previews: some View {
        BottleCardDetailedView(bottle: Binding.constant(sampleBottle), isShowingDetail: Binding.constant(true))
    }
}
