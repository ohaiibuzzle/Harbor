import SwiftUI

private struct XCLIUtilsEnvironmentKey: EnvironmentKey {
    static var defaultValue: XCLIUtils = .init()
}

extension EnvironmentValues {
    var xcliUtils: XCLIUtils {
            get { self[XCLIUtilsEnvironmentKey.self] }
            set { self[XCLIUtilsEnvironmentKey.self] = newValue }
    }
}

