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
            Text("Launch an External App")
                .font(.title)
                .padding()
            
            Text("The application will be copied to and launched from prefix \(bottle.name)")
                .padding()
            Grid {
                GridRow {
                    Text("Application: ")
                    HStack {
                        TextField("MyApp.exe", text: $applicationPath)
                        Button("Browse") {
                            let dialog = NSOpenPanel()
                            dialog.title = "Choose an application to launch"
                            dialog.showsResizeIndicator = true
                            dialog.showsHiddenFiles = false
                            dialog.canChooseDirectories = false
                            dialog.canChooseFiles = true
                            dialog.canCreateDirectories = false
                            dialog.allowsMultipleSelection = false
                            dialog.allowedFileTypes = ["exe", "msi"]
                            dialog.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                            if dialog.runModal() == NSApplication.ModalResponse.OK {
                                let result = dialog.url
                                if result != nil {
                                    applicationPath = result!.path
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
                    Text("Arguments: ")
                    TextField("", text: $applicationArgument)
                }
                .padding()
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                Button("Launch") {
                    bottle.launchApplication(applicationPath, arguments: bottle.primaryApplicationArgument.split(separator: " ").map { String($0) })
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
    LaunchExtDropdown(isPresented: Binding.constant(true), bottle: BottleModel(id: UUID(), name: "Demo", path: URL(fileURLWithPath: "")))
}
