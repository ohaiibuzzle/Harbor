import SwiftUI

private struct GPKUtilsEnvironmentKey: EnvironmentKey {
    static let defaultValue: GPKUtils = .init()
}

extension EnvironmentValues {
    var gpkUtils: GPKUtils {
            get { self[GPKUtilsEnvironmentKey.self] }
            set { self[GPKUtilsEnvironmentKey.self] = newValue }
    }
}
