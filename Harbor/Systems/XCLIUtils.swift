//
//  XCLIUtils.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import Foundation
import Observation

@Observable
final class XCLIUtils {
    var installed = false

    init() {
        checkXcliInstalled()
    }

    func checkXcliInstalled() {
        // SANITY: Check if /Library/Developer/CommandLineTools exists
        guard FileManager.default.fileExists(atPath: "/Library/Developer/CommandLineTools") else {
            installed = false
            return
        }

        // pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
        // Looking for 'version: 15.0.0.0.1.1685693485'
        let task = Process()
        task.launchPath = "/usr/sbin/pkgutil"
        task.arguments = ["--pkg-info=com.apple.pkg.CLTools_Executables"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            installed = output.contains("version: 15.")
        }
    }
}
