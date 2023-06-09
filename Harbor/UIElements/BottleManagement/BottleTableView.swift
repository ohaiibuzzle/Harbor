//
//  Toolbar.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct BottleTableView: View {
    @Binding var bottles: [BottleModel]
    @Binding var selectedBottle: BottleModel.ID?
    
    @Binding var showNewBottleSheet: Bool
    @Binding var showEditBottleSheet: Bool
    @Binding var showLaunchExtSheet: Bool
    
    @State private var sortOrder = [KeyPathComparator(\BottleModel.name)]
    
    var body: some View {
        
    }
}
