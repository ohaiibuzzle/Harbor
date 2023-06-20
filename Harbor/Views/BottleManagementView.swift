//
//  BottleManagementView.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI
import Observation

enum BottleManagementViewModes: String, CaseIterable, Identifiable {
    var id: Self { self }

    case table
    case card
}

struct BottleManagementView: View {
    @Bindable var menuUIStates: MenuUIStates
    @AppStorage("ViewMode") var viewMode: BottleManagementViewModes = .card
    var body: some View {
        Group {
            if viewMode == .card {
                BottleManagementCardView()
            } else {
                BottleManagementTableView()
            }
        }
        .sheet(isPresented: $menuUIStates.shouldShowDXVKSheet) {
            DXVKInstallView(isPresented: $menuUIStates.shouldShowDXVKSheet)
        }
    }
}

#Preview {
    BottleManagementView(menuUIStates: MenuUIStates())
}
