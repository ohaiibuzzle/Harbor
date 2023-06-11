//
//  NewBottleDropdown.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct NewBottleDropdown: View {
    @Binding var isPresented: Bool
    @Binding var bottle: BottleModel
    var editingMode: Bool = false

    @State var bottleName = ""

    var body: some View {
        VStack {
            Text("New Bottle")
                .font(.title)
                .padding()

            HStack {
                Text("Name")
                TextField("My Bottle", text: $bottle.name)
            }

            // Browsable file picker for new bottle folder
            HStack {
                Group {
                    Text("Path")
                    TextField("", text: $bottleName)
                    Button("Browse") {
                        let dialog = NSOpenPanel()
                        dialog.title = "Choose a folder for your new bottle"
                        dialog.showsResizeIndicator = true
                        dialog.showsHiddenFiles = false
                        dialog.canChooseDirectories = true
                        dialog.canChooseFiles = false
                        dialog.canCreateDirectories = true
                        dialog.allowsMultipleSelection = false
                        dialog.directoryURL = FileManager.default
                            .urls(for: .documentDirectory, in: .userDomainMask).first
                        if dialog.runModal() == NSApplication.ModalResponse.OK {
                            let result = dialog.url
                            if result != nil {
                                bottleName = result!.path
                            }
                        } else {
                            // User clicked on "Cancel"
                            return
                        }
                    }
                }
                .onChange(of: bottleName, perform: { value in
                    bottle.path = URL(fileURLWithPath: value)
                })
            }

            if editingMode {
                // Primary application
                HStack {
                    Text("Primary Application")
                    TextField("MyApp.exe", text: $bottle.primaryApplicationPath)
                }
                HStack {
                    Text("Primary Application Argument")
                    TextField("", text: $bottle.primaryApplicationArgument)
                }
            }

            // Cancel and Create buttons
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Button(editingMode ? "Save" : "Create") {
                    if editingMode {
                        // Save the bottle
                        BottleLoader.shared.bottles = BottleLoader.shared.bottles.map { (bottle) -> BottleModel in
                            if bottle.id == self.bottle.id {
                                return self.bottle
                            } else {
                                return bottle
                            }
                        }
                    } else {
                        // Create the bottle
                        let newBottle = BottleModel(id: UUID(), name: bottle.name, path: bottle.path)
                        BottleLoader.shared.bottles.append(newBottle)
                    }
                }
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

struct EditBottleView: View {
    @Binding var isPresented: Bool
    @Binding var bottle: BottleModel

    @State var bottleName = ""

    var body: some View {
        // Basically reuse New in editing mode
        NewBottleDropdown(isPresented: $isPresented, bottle: $bottle, editingMode: true)
    }

}

#Preview {
    NewBottleDropdown(isPresented: Binding.constant(true),
                      bottle: Binding.constant(BottleModel(
                        id: UUID(), name: "My Bottle", path: URL(fileURLWithPath: "/Users/venti/Documents/My Bottle"))))
}
