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
        .onChange(of: sortOrder) { newOrder in
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
                    BottleLoader.shared.delete(bottles.first(where: { $0.id == selectedBottle })!)
                    bottles.removeAll(where: { $0.id == selectedBottle })
                    selectedBottle = nil
                } label: {
                    Label("Nuke", systemImage: "trash")
                }
                .disabled(selectedBottle == nil)
            }
        }
        
        .sheet(isPresented: $showNewBottleSheet) {
            NewBottleDropdown(isPresented: $showNewBottleSheet, bottle: BottleModel(id: UUID(), name: "", path: URL(fileURLWithPath: "")))
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
