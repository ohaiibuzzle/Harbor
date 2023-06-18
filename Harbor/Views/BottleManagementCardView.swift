//
//  BottleManagementCardView.swift
//  Harbor
//
//  Created by Venti on 18/06/2023.
//

import SwiftUI

struct BottleManagementCardView: View {
    @State private var bottleState = BottleList()
    @State private var selectedBottle: HarborBottle.ID?

    @State private var showNewBottleSheet = false
    @State private var showLaunchExtSheet = false
    @State private var showBottleDetail = false

    @State private var sortOrder = [KeyPathComparator(\HarborBottle.name)]

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text("home.bottles.title")
                        .font(.title)
                        .padding()
                    Text("home.bottles.subtitle")
                        .padding()
                        .multilineTextAlignment(.center)
                }
                BottleCardListView(bottles: bottleState, isShowingDetails: $showBottleDetail)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showNewBottleSheet = true
                    } label: {
                        Label("home.btn.new", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewBottleSheet) {
                NewBottleDropdown(isPresented: $showNewBottleSheet,
                                  bottle: HarborBottle(id: UUID(), name: "", path: URL(fileURLWithPath: "")))
            }
            .sheet(isPresented: $showLaunchExtSheet) {
                if let thisBottle = bottleState.bottles.first(where: { $0.id == selectedBottle }) {
                    LaunchExtDropdown(isPresented: $showLaunchExtSheet,
                                      bottle: thisBottle)
                }
            }
            .onChange(of: showNewBottleSheet) {
                bottleState.reload()
            }
            .onChange(of: showBottleDetail) {
                bottleState.reload()
            }
        }
    }
}

struct BottleManagementCardView_Previews: PreviewProvider {
    static var previews: some View {
        BottleManagementCardView()
    }
}
