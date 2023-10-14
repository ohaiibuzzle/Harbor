//
//  NewBottleDropdown.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct NewBottleDropdown: View {
    @Binding var isPresented: Bool
    var editingMode: Bool = false

    @State var bottle: HarborBottle
    @State var bottlePath = ""
    @State var isWorking = false

    let monospaceFont = Font.body.monospaced()

    var body: some View {
        ZStack {
            VStack {
                Text(editingMode ? "sheet.edit.title" : "sheet.new.title")
                    .font(.title)
                    .padding()

                Spacer()

                Form {
                    Section {
                        HStack {
                            Text("sheet.new.bottleNameLabel")
                            TextField("", text: $bottle.name)
                                .onChange(of: bottle.name) { oldValue, newValue in
                                    // Prevent it from being empty
                                    if newValue == "" {
                                        bottle.name = oldValue
                                    } else {
                                        bottle.name = newValue
                                    }
                                }
                        }
                    }

                    // Browsable file picker for new bottle folder
                    Section {
                        HStack {
                            Text("sheet.new.bottlePathLabel")
                            TextField("", text: $bottlePath)
                                .font(monospaceFont)
                            Button("btn.browse") {
                                let dialog = NSOpenPanel()
                                dialog.title = "sheet.new.title"
                                dialog.showsResizeIndicator = true
                                dialog.showsHiddenFiles = false
                                dialog.canChooseDirectories = true
                                dialog.canChooseFiles = false
                                dialog.canCreateDirectories = true
                                dialog.allowsMultipleSelection = false
                                dialog.directoryURL = FileManager.default
                                    .urls(for: .documentDirectory, in: .userDomainMask).first
                                if dialog.runModal() == NSApplication.ModalResponse.OK {
                                    if let result = dialog.url {
                                        bottlePath = result.path
                                    }
                                } else {
                                    // User clicked on "Cancel"
                                    return
                                }
                            }
                        }
                        .onChange(of: bottlePath) { _, value in
                            bottle.path = URL(fileURLWithPath: value)
                        }
                    }
                    .disabled(editingMode)

                    if editingMode {
                        Section {
                            HStack {
                                Text("sheet.edit.primaryAppLabel")
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
                            HStack {
                                Text("sheet.edit.primaryAppArgsLabel")
                                TextField("", text: $bottle.primaryApplicationArgument)
                            }
                            HStack {
                                Text("sheet.edit.primaryAppWorkDirLabel")
                                TextField("", text: $bottle.primaryApplicationWorkDir)
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
                }
                .formStyle(.grouped)

                Spacer()

                // Cancel and Create buttons
                HStack {
                    Button("btn.cancel") {
                        isPresented = false
                    }
                    Button(editingMode ? "btn.done" : "btn.create") {
                        if editingMode {
                            // Save the bottle
                            if let bottleIndex = BottleLoader.shared.bottles.firstIndex(where: { $0.id == bottle.id }) {
                                BottleLoader.shared.bottles[bottleIndex] = bottle
                            }
                            isPresented = false
                        } else {
                            // Create the bottle
                            isWorking = true
                            Task.detached {
                                // We quickly check the dir. If it contains Wine file structure (eg. drive_c)
                                // create the bottle WITH it.
                                // Otherwise, create the bottle with the name as the new directory.
                                let isWineDir = FileManager.default
                                    .fileExists(atPath: bottle.path.appendingPathComponent("drive_c").path)
                                if !isWineDir {
                                    let newDir = bottle.path.appendingPathComponent(bottle.name)
                                    try? FileManager.default
                                        .createDirectory(at: newDir, withIntermediateDirectories: true, attributes: nil)
                                    bottle.path = newDir
                                }
                                bottle.initializeBottle()
                                Task { @MainActor in
                                    BottleLoader.shared.bottles.append(bottle)
                                    isWorking = false
                                    isPresented = false
                                }
                            }
                        }
                    }
                    .disabled(bottle.name == "" || bottle.path.absoluteString == "file:///" || isWorking)
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
                .padding()
            }
            .disabled(isWorking)
            if isWorking {
                // Bar indicating progress
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.regular)
            }
        }
        .padding()
        .frame(minWidth: 500)
    }
}

struct EditBottleView: View {
    @Binding var isPresented: Bool
    var bottle: HarborBottle
    var body: some View {
        // Basically reuse New in editing mode
        NewBottleDropdown(isPresented: $isPresented, editingMode: true,
                          bottle: bottle, bottlePath: bottle.path.absoluteString)
    }

}

struct NewBottleDropdown_Previews: PreviewProvider {
    static var previews: some View {
        EditBottleView(isPresented: Binding.constant(true),
                          bottle: HarborBottle(id: UUID(), name: "My Bottle",
                                               path: URL(fileURLWithPath: "/Users/venti/Documents/My Bottle")))
        .environment(\.xcliUtils, .init())
    }
}
