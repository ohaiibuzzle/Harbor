//
//  MenuUIState.swift
//  Harbor
//
//  Created by Venti on 19/06/2023.
//

import Foundation
import Observation

@Observable
final class MenuUIStates {
    // This class is for stuff that needs to be passed between
    // the menu items and the UI elements (eg. sheets within views)
    var shouldShowDXVKSheet = false
}
