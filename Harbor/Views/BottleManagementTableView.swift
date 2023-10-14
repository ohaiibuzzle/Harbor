//
//  BottleManagementTableView.swift
//  Harbor
//
//  Created by Venti on 18/06/2023.
//

import SwiftUI

struct BottleManagementTableView: View {
    @State private var bottleState = BottleList()
    @State private var selectedBottle: HarborBottle.ID?

    @State private var showNewBottleSheet = false
    @State private var showEditBottleSheet = false
    @State private var showLaunchExtSheet = false
    @State private var showAdvConfigSheet = false

    @State private var sortOrder = [KeyPathComparator(\HarborBottle.name)]
    var body: some View {
        VStack {
            VStack {
                Text("home.bottles.title")
                    .font(.title)
                    .padding()
                Text("home.bottles.subtitle")
                    .padding()
                    .multilineTextAlignment(.center)
            }

            Table(bottleState.bottles, selection: $selectedBottle, sortOrder: $sortOrder) {
                TableColumn("home.table.name", value: \.name)
                TableColumn("home.table.path", value: \.path.prettyFileUrl)
                TableColumn("home.table.primaryApp", value: \.primaryApplicationPath)
            }
            .padding()
            .frame(minWidth: 500, minHeight: 200)
            .onChange(of: sortOrder) { _, newOrder in
                bottleState.bottles.sort(using: newOrder)
            }
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
                    if let thisBottle = bottleState.bottles.first(where: { $0.id == selectedBottle }) {
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
                    if let thisBottle = bottleState.bottles.first(where: { $0.id == selectedBottle }) {
                        thisBottle.killBottle()
                    }
                } label: {
                    Label("home.btn.kill", systemImage: "stop")
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
                    if let thisBottle = bottleState.bottles.first(where: { $0.id == selectedBottle }) {
                        // ALARM
                        let alert = NSAlert()
                        alert.messageText = String(localized: "home.alert.deleteTitle")
                        alert.alertStyle = .critical
                        let checkbox = NSButton(checkboxWithTitle:
                                                    String(format: String(localized: "home.alert.deletePath %@"),
                                                           thisBottle.path.prettyFileUrl), target: nil, action: nil)
                        checkbox.state = .on
                        alert.accessoryView = checkbox
                        alert.addButton(withTitle: String(localized: "btn.delete"))
                        alert.addButton(withTitle: String(localized: "btn.cancel"))
                        if alert.runModal() == .alertFirstButtonReturn {
                            // User clicked on "Delete"
                            if let thisBottle = bottleState.bottles.first(where: { $0.id == selectedBottle }) {
                                BottleLoader.shared.delete(thisBottle, checkbox.state)
                                bottleState.bottles.removeAll(where: { $0.id == selectedBottle })
                                bottleState.flush()
                                bottleState.reload()
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
                              bottle: HarborBottle(id: UUID(), name: "", path: URL(fileURLWithPath: "")))
        }
        .sheet(isPresented: $showEditBottleSheet) {
            if let thisBottle = bottleState.bottles.first(where: { $0.id == selectedBottle }) {
                EditBottleView(isPresented: $showEditBottleSheet,
                               bottle: thisBottle)
            }
        }
        .sheet(isPresented: $showLaunchExtSheet) {
            if let thisBottle = bottleState.bottles.first(where: { $0.id == selectedBottle }) {
                LaunchExtDropdown(isPresented: $showLaunchExtSheet,
                                  bottle: thisBottle)
            }
        }
        .sheet(isPresented: $showAdvConfigSheet) {
            if let thisBottle = $bottleState.bottles.first(where: { $0.id == selectedBottle }) {
                BottleConfigDropdown(isPresented: $showAdvConfigSheet,
                                     bottle: thisBottle)
            }
        }
        .onChange(of: showNewBottleSheet) {
            bottleState.reload()
        }
        .onChange(of: showEditBottleSheet) {
            bottleState.reload()
        }

    }
}

struct BottleManagementTableView_Previews: PreviewProvider {
    static var previews: some View {
        BottleManagementTableView()
    }
}
