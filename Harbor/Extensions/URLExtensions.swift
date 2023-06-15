//
//  URLExtensions.swift
//  Harbor
//
//  Created by Venti on 15/06/2023.
//

import Foundation

extension URL {
    var prettyFileUrl: String {
        if !self.isFileURL {
            return self.absoluteString
        }
        guard var prettyPath = self.path.removingPercentEncoding else {
            return self.path
        }

        if path.hasPrefix("/Users") {
            // Remove /Users/<username> and replace with ~
            prettyPath = prettyPath.replacingOccurrences(of: #"/Users/[^/]+/"#,
                                                         with: "~/", options: .regularExpression)
        }

        return prettyPath
    }
}
