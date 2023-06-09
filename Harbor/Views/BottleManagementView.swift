//
//  BottleManagementView.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct BottleManagementView: View {
    @State private var bottles = BottleLoader.shared.bottles
    @State private var selectedBottle: BottleModel.ID?
    
    @State private var showNewBottleSheet = false
    @State private var showEditBottleSheet = false
    @State private var showLaunchExtSheet = false
    @State private var showAdvConfigSheet = false
    
    @State private var sortOrder = [KeyPathComparator(\BottleModel.name)]
    var body: some View {
        VStack {
            Text("Your Wine Bottles")
                .font(.title)
                .padding()
            
            Text("Wine bottles are separate environments that you can use to install Windows applications. \nYou can create as many bottles as you want, and each bottle can have its own Windows version and configuration.")
                .padding()
                .multilineTextAlignment(.center)
        }
        
        Table(bottles, selection: $selectedBottle, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Path", value: \.path.relativeString)
            TableColumn("Primary Application", value: \.primaryApplicationPath)
        }
        .padding()
        .frame(minWidth: 500, minHeight: 200)
        .onChange(of: sortOrder) { oldOrder, newOrder in
            bottles.sort(using: newOrder)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showNewBottleSheet = true
                } label: {
                    Label("New", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showEditBottleSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    bottles.first(where: { $0.id == selectedBottle })!.launchPrimaryApplication()
                } label: {
                    Label("Run", systemImage: "play")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showLaunchExtSheet = true
                } label: {
                    Label("Run External", systemImage: "tray.and.arrow.down")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showAdvConfigSheet = true
                } label: {
                    Label("Advanced Config", systemImage: "gear")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    // ALARM
                    let alert = NSAlert()
                    alert.messageText = "Are you sure you want to delete this bottle?"
                    alert.informativeText = "Deleting this bottle will INSTANTLY destroy every data in \(bottles.first(where: { $0.id == selectedBottle })!.path.absoluteString). This action cannot be undone."
                    alert.alertStyle = .critical
                    alert.addButton(withTitle: "Delete")
                    alert.addButton(withTitle: "Cancel")

                    if alert.runModal() == .alertFirstButtonReturn {
                        // User clicked on "Delete"
                        BottleLoader.shared.delete(bottles.first(where: { $0.id == selectedBottle })!)
                        bottles.removeAll(where: { $0.id == selectedBottle })
                        selectedBottle = nil
                    } else {
                        // User clicked on "Cancel"
                        return
                    }
                } label: {
                    Label("Nuke", systemImage: "trash")
                }
                .disabled(selectedBottle == nil)
            }
        }
        
        .sheet(isPresented: $showNewBottleSheet) {
            NewBottleDropdown(isPresented: $showNewBottleSheet, bottle: BottleModel(id: UUID(), path: URL(fileURLWithPath: "")))
        }
        .sheet(isPresented: $showEditBottleSheet) {
            EditBottleView(isPresented: $showEditBottleSheet, bottle: bottles.first(where: { $0.id == selectedBottle })!)
        }
        .sheet(isPresented: $showLaunchExtSheet) {
            LaunchExtDropdown(isPresented: $showLaunchExtSheet, bottle: bottles.first(where: { $0.id == selectedBottle })!)
        }
        .sheet(isPresented: $showAdvConfigSheet) {
            BottleConfigDropdown(isPresented: $showAdvConfigSheet, bottle: $bottles.first(where: { $0.id == selectedBottle })!)
        }
        .onChange(of: showNewBottleSheet) {
            bottles = BottleLoader.shared.bottles
        }
        .onChange(of: showEditBottleSheet) {
            bottles = BottleLoader.shared.bottles
        }
        
    }
}

#Preview {
    BottleManagementView()
}
