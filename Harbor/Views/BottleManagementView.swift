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
    @AppStorage("ViewMode") var viewMode: BottleManagementViewModes = .table
    var body: some View {
        if viewMode == .card {
            BottleManagementCardView()
        } else {
            BottleManagementTableView()
        }
    }
}

#Preview {
    BottleManagementView()
}
