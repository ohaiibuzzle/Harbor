import SwiftUI

private struct BrewUtilsEnvironmentKey: EnvironmentKey {
    static var defaultValue: BrewUtils = .init()
}

extension EnvironmentValues {
    var brewUitls: BrewUtils {
            get { self[BrewUtilsEnvironmentKey.self] }
            set { self[BrewUtilsEnvironmentKey.self] = newValue }
    }
}

