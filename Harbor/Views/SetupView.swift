//
//  SetupView.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct SetupView: View {
    @State var isXcliInstallerDropdownShown = false
    @State var isBrewInstallerDropdownShown = false
    @State var isGPKSafeInstallerDropdownShown = false
    @State var isGPKFastInstallerDropdownShown = false

    @Environment(\.brewUtils)
    var brewUtils

    @Environment(\.xcliUtils)
    var xcliUtils

    var body: some View {
        VaporwareSetupUI()
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
            .environment(\.brewUtils, .init())
            .environment(\.xcliUtils, .init())
    }
}
