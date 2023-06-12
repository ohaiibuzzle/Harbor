//
//  LaunchExtDropdown.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct LaunchExtDropdown: View {
    @Binding var isPresented: Bool
    var bottle: BottleModel

    @State var applicationPath = ""
    @State var applicationArgument = ""

    var body: some View {
        VStack {
            Text("sheet.launchExt.title")
                .font(.title)
                .padding()

            Text("sheet.launchExt.subtitle \(bottle.name)")
                .padding()
            Grid {
                GridRow {
                    Text("sheet.launchExt.applicationLabel")
                    HStack {
                        TextField("MyApp.exe", text: $applicationPath)
                        Button("btn.browse") {
                            let dialog = NSOpenPanel()
                            dialog.title = "sheet.launchExt.title"
                            dialog.showsResizeIndicator = true
                            dialog.showsHiddenFiles = false
                            dialog.canChooseDirectories = false
                            dialog.canChooseFiles = true
                            dialog.canCreateDirectories = false
                            dialog.allowsMultipleSelection = false
                            dialog.allowedFileTypes = ["exe", "msi"]
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
                .padding()

                GridRow {
                    Text("sheet.launchExt.argsLabel")
                    TextField("", text: $applicationArgument)
                }
                .padding()
            }

            HStack {
                Spacer()
                Button("btn.cancel") {
                    isPresented = false
                }
                Button("btn.launch") {
                    bottle.launchApplication(applicationPath,
                                             arguments: bottle.primaryApplicationArgument
                                                .split(separator: " ").map { String($0) })
                    isPresented = false
                }
                .disabled(applicationPath.isEmpty)
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    LaunchExtDropdown(isPresented: Binding.constant(true),
                      bottle: BottleModel(id: UUID(), name: "Demo", path: URL(fileURLWithPath: "")))
}
