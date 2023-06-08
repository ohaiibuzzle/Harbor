//
//  BottleManagementView.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct BottleManagementView: View {
    @State private var bottles = BottleLoader.shared.bottles
    @State private var sortOrder = [KeyPathComparator(\BottleModel.name)]
    @State private var selectedBottle: BottleModel.ID?
    
    @State private var showNewBottleSheet = false
    @State private var showEditBottleSheet = false
    @State private var showLaunchExtSheet = false
    
    var body: some View {
        VStack {
            Text("Your Wine Bottles")
                .font(.title)
                .padding()
            
            Text("Wine bottles are separate environments that you can use to install Windows applications. You can create as many bottles as you want, and each bottle can have its own Windows version and configuration.")
                .padding()
                .multilineTextAlignment(.center)
            
            // Table View
            Table(bottles, selection: $selectedBottle, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.name)
                TableColumn("Path", value: \.path.relativeString)
                TableColumn("Primary Application", value: \.primaryApplicationPath)
            }
            .padding()
            .frame(minWidth: 500, minHeight: 300)
            .onChange(of: sortOrder) { newOrder in
                bottles.sort(using: newOrder)
            }
            HStack {
                Group {
                    Spacer()
                    // Five buttons: New Bottle, Edit Bottle, Launch Bottle, Launch External Application, Delete Bottle
                    VStack {
                        Button {
                            showNewBottleSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        Text("New")
                    }
                    .padding()
                    Spacer()
                    VStack {
                        Button {
                            showEditBottleSheet = true
                        } label: {
                            Image(systemName: "pencil")
                            
                        }
                        Text("Edit")
                    }
                    .padding()
                    .disabled(selectedBottle == nil)
                    Spacer()
                }
                Group {
                    VStack {
                        Button {
                            bottles.first(where: { $0.id == selectedBottle })!.launchPrimaryApplication()
                        } label: {
                            Image(systemName: "play")
                        }
                        Text("Launch")
                    }
                    .padding()
                    .disabled(selectedBottle == nil)
                    Spacer()
                    VStack {
                        Button {
                            showLaunchExtSheet = true
                        } label: {
                            Image(systemName: "play.rectangle")
                        }
                        Text("Launch Ext.")
                    }
                    .padding()
                    .disabled(selectedBottle == nil)
                    Spacer()
                    VStack {
                        Button {
                            BottleLoader.shared.delete(bottles.first(where: { $0.id == selectedBottle })!)
                            bottles.removeAll(where: { $0.id == selectedBottle })
                            selectedBottle = nil
                        } label: {
                            Image(systemName: "trash")
                        }
                        Text("Nuke")
                    }
                    .padding()
                    .disabled(selectedBottle == nil)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showNewBottleSheet) {
            NewBottleDropdown(isPresented: $showNewBottleSheet, bottle: BottleModel(id: UUID(), name: "", path: URL(fileURLWithPath: "")))
        }
        .sheet(isPresented: $showEditBottleSheet) {
            EditBottleView(isPresented: $showEditBottleSheet, bottle: bottles.first(where: { $0.id == selectedBottle })!)
        }
        .sheet(isPresented: $showLaunchExtSheet, content: {
            LaunchExtDropdown(isPresented: $showLaunchExtSheet, bottle: bottles.first(where: { $0.id == selectedBottle })!)
        })
        .onChange(of: showNewBottleSheet) {
            bottles = BottleLoader.shared.bottles
        }
        .onChange(of: showEditBottleSheet) {
            bottles = BottleLoader.shared.bottles
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}

#Preview {
    BottleManagementView()
}
