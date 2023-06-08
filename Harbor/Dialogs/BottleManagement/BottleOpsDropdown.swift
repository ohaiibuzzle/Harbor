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

    @State var bottle: BottleModel
    @State var bottleName = ""
    @State var bottlePath = ""
    @State var isWorking = false
    
    var body: some View {
        VStack {
            Text(editingMode ? "Edit Bottle" : "New Bottle")
                .font(.title)
                .padding()
            
            Group {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("My Bottle", text: $bottle.name)
                        .frame(width: 125)
                }
                
                // Browsable file picker for new bottle folder
                HStack {
                    Group {
                        Text("Path")
                        Spacer()
                        TextField("", text: $bottlePath)
                            .frame(width: 125)
                        Button("Browse") {
                            let dialog = NSOpenPanel()
                            dialog.title = "Choose a folder for your new bottle"
                            dialog.showsResizeIndicator = true
                            dialog.showsHiddenFiles = false
                            dialog.canChooseDirectories = true
                            dialog.canChooseFiles = false
                            dialog.canCreateDirectories = true
                            dialog.allowsMultipleSelection = false
                            dialog.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                            if dialog.runModal() == NSApplication.ModalResponse.OK {
                                let result = dialog.url
                                if result != nil {
                                    bottlePath = result!.path
                                }
                            } else {
                                // User clicked on "Cancel"
                                return
                            }
                        }
                    }
                    .onChange(of: bottlePath, perform: { value in
                        bottle.path = URL(fileURLWithPath: value)
                    })
                }
                .disabled(editingMode)
            }

            if editingMode {
                Group {
                    // Primary application
                    HStack {
                        Text("Primary Application")
                        Spacer()
                        TextField("MyApp.exe", text: $bottle.primaryApplicationPath)
                            .frame(width: 125)
                        Button("Browse") {
                            let dialog = NSOpenPanel()
                            dialog.title = "Choose a primary application for your bottle"
                            dialog.showsResizeIndicator = true
                            dialog.showsHiddenFiles = false
                            dialog.canChooseDirectories = false
                            dialog.canChooseFiles = true
                            dialog.canCreateDirectories = false
                            dialog.allowsMultipleSelection = false
                            dialog.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                            if dialog.runModal() == NSApplication.ModalResponse.OK {
                                let result = dialog.url
                                if result != nil {
                                    bottle.primaryApplicationPath = bottle.appPathFromUnixPath(result!)
                                }
                            } else {
                                // User clicked on "Cancel"
                                return
                            }
                        }
                    }
                    HStack {
                        Text("Primary Application Argument")
                        Spacer()
                        TextField("", text: $bottle.primaryApplicationArgument)
                            .frame(width: 125)
                    }
                }
            }
            
            if isWorking {
                // Bar indicating progress
                ProgressView()
                    .progressViewStyle(.linear)
                    .padding()
            }

            // Cancel and Create buttons
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Button(editingMode ? "Save" : "Create") {
                    if editingMode {
                        // Save the bottle
                        isPresented = false
                        BottleLoader.shared.bottles = BottleLoader.shared.bottles.map { (bottle) -> BottleModel in
                            if bottle.id == self.bottle.id {
                                return self.bottle
                            } else {
                                return bottle
                            }
                        }
                    } else {
                        // Create the bottle
                        isWorking = true
                        Task.detached {
                            bottle.initializeBottle()
                            Task { @MainActor in
                                BottleLoader.shared.bottles.append(bottle)
                                isWorking = false
                                isPresented = false
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
        .frame(width: 500, height: 300)
    }
}

struct EditBottleView: View {
    @Binding var isPresented: Bool
    var bottle: BottleModel
    var body: some View {
        // Basically reuse New in editing mode
        NewBottleDropdown(isPresented: $isPresented, editingMode: true, bottle: bottle, bottleName: bottle.name, bottlePath: bottle.path.absoluteString)
    }

}

#Preview {
    NewBottleDropdown(isPresented: Binding.constant(true), bottle: BottleModel(id: UUID(), name: "My Bottle", path: URL(fileURLWithPath: "/Users/venti/Documents/My Bottle")))
}
