import SwiftUI

private struct BrewUtilsEnvironmentKey: EnvironmentKey {
    static var defaultValue: BrewUtils = .init()
}

extension EnvironmentValues {
    var brewUtils: BrewUtils {
            get { self[BrewUtilsEnvironmentKey.self] }
            set { self[BrewUtilsEnvironmentKey.self] = newValue }
    }
}
