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
            Text("home.bottles.title")
                .font(.title)
                .padding()

            Text("home.bottles.subtitle")
                .padding()
                .multilineTextAlignment(.center)
        }

        Table(bottles, selection: $selectedBottle, sortOrder: $sortOrder) {
            TableColumn("home.table.name", value: \.name)
            TableColumn("home.table.path", value: \.path.relativeString)
            TableColumn("home.table.primaryApp", value: \.primaryApplicationPath)
        }
        .padding()
        .frame(minWidth: 500, minHeight: 200)
        .onChange(of: sortOrder) { _, newOrder in
            bottles.sort(using: newOrder)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showNewBottleSheet = true
                } label: {
                    Label("home.btn.new", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showEditBottleSheet = true
                } label: {
                    Label("home.btn.edit", systemImage: "pencil")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    if let thisBottle = bottles.first(where: { $0.id == selectedBottle }) {
                        thisBottle.launchPrimaryApplication()
                    }
                } label: {
                    Label("home.btn.run", systemImage: "play")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showLaunchExtSheet = true
                } label: {
                    Label("home.btn.runExt", systemImage: "tray.and.arrow.down")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showAdvConfigSheet = true
                } label: {
                    Label("home.btn.advConf", systemImage: "gear")
                }
                .disabled(selectedBottle == nil)
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    if let thisBottle = bottles.first(where: { $0.id == selectedBottle }) {
                        // ALARM
                        let alert = NSAlert()
                        alert.messageText = String(localized: "home.alert.deleteTitle")
                        alert.alertStyle = .critical
                        let checkbox = NSButton(checkboxWithTitle:
                                                    String(format: String(localized: "home.alert.deletePath %@"),
                                                           thisBottle.path.absoluteString), target: nil, action: nil)
                        checkbox.state = .on
                        alert.accessoryView = checkbox
                        alert.addButton(withTitle: String(localized: "btn.delete"))
                        alert.addButton(withTitle: String(localized: "btn.cancel"))

                        if alert.runModal() == .alertFirstButtonReturn {
                            // User clicked on "Delete"
                            if let thisBottle = bottles.first(where: { $0.id == selectedBottle }) {
                                BottleLoader.shared.delete(thisBottle, checkbox.state)
                                bottles.removeAll(where: { $0.id == selectedBottle })
                                selectedBottle = nil
                            }
                        } else {
                            // User clicked on "Cancel"
                            return
                        }
                    }
                } label: {
                    Label("home.btn.nuke", systemImage: "trash")
                }
                .disabled(selectedBottle == nil)
            }
        }

        .sheet(isPresented: $showNewBottleSheet) {
            NewBottleDropdown(isPresented: $showNewBottleSheet,
                              bottle: BottleModel(id: UUID(), path: URL(fileURLWithPath: "")))
        }
        .sheet(isPresented: $showEditBottleSheet) {
            if let thisBottle = bottles.first(where: { $0.id == selectedBottle }) {
                EditBottleView(isPresented: $showEditBottleSheet,
                               bottle: thisBottle)
            }
        }
        .sheet(isPresented: $showLaunchExtSheet) {
            if let thisBottle = bottles.first(where: { $0.id == selectedBottle }) {
                LaunchExtDropdown(isPresented: $showLaunchExtSheet,
                                  bottle: thisBottle)
            }
        }
        .sheet(isPresented: $showAdvConfigSheet) {
            if let thisBottle = $bottles.first(where: { $0.id == selectedBottle }) {
                BottleConfigDropdown(isPresented: $showAdvConfigSheet,
                                     bottle: thisBottle)
            }
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
