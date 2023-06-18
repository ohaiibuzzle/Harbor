//
//  LaunchExtDropdown.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct LaunchExtDropdown: View {
    @Binding var isPresented: Bool
    var bottle: HarborBottle

    @State var applicationPath = ""
    @State var applicationArgument = ""
    @State var applicationWorkDir = ""

    var body: some View {
        VStack {
            Text("sheet.launchExt.title")
                .font(.title)
                .padding()

            Text("sheet.launchExt.subtitle \(bottle.name)")
                .padding()
            Form {
                Section {
                    HStack {
                        TextField("sheet.launchExt.applicationLabel", text: $applicationPath)
                        Button("btn.browse") {
                            let dialog = NSOpenPanel()
                            dialog.title = "sheet.launchExt.title"
                            dialog.showsResizeIndicator = true
                            dialog.showsHiddenFiles = false
                            dialog.canChooseDirectories = false
                            dialog.canChooseFiles = true
                            dialog.canCreateDirectories = false
                            dialog.allowsMultipleSelection = false
                            dialog.allowedContentTypes = [.exe, UTType(importedAs: "harbor.msi-package")]
                            dialog.directoryURL = bottle.path
                            if dialog.runModal() == NSApplication.ModalResponse.OK {
                                if let result = dialog.url {
                                    applicationPath = result.path
                                }
                            } else {
                                // User clicked on "Cancel"
                                return
                            }
                        }
                    }
                }

                Section {
                    TextField("sheet.launchExt.argsLabel", text: $applicationArgument)
                }

                Section {
                    HStack {
                        TextField("sheet.launchExt.appWorkDirLabel", text: $applicationWorkDir)
                        Button("btn.browse") {
                            let dialog = NSOpenPanel()
                            dialog.title = "sheet.launchExt.workDir.popup"
                            dialog.showsResizeIndicator = true
                            dialog.showsHiddenFiles = false
                            dialog.canChooseDirectories = true
                            dialog.canChooseFiles = false
                            dialog.canCreateDirectories = true
                            dialog.allowsMultipleSelection = false
                            dialog.directoryURL = bottle.path
                            if dialog.runModal() == NSApplication.ModalResponse.OK {
                                if let result = dialog.url {
                                    applicationWorkDir = bottle.pathFromUnixPath(result)
                                }
                            } else {
                                // User clicked on "Cancel"
                                return
                            }
                        }
                    }
                }
            }
            .padding()
            .formStyle(.automatic)

            HStack {
                Spacer()
                Button("btn.cancel") {
                    isPresented = false
                }
                Button("btn.launch") {
                    bottle.launchExtApplication(applicationPath,
                                                arguments: applicationArgument.components(separatedBy: " "),
                                             workDir: applicationWorkDir)
                    isPresented = false
                }
                .disabled(applicationPath.isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                Spacer()
            }
        }
        .padding()
    }
}

struct LaunchExtDropdown_Previews: PreviewProvider {
    static var previews: some View {
        LaunchExtDropdown(isPresented: Binding.constant(true),
                          bottle: HarborBottle(id: UUID(), name: "Demo", path: URL(fileURLWithPath: "")))
        .environment(\.brewUtils, .init())
    }
}
