//
//  XCLIUtils.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import Foundation

struct XCLIUtils {
    static let shared = XCLIUtils()
    
    func checkXcliInstalled() -> Bool {
        // SANITY: Check if /Library/Developer/CommandLineTools exists
        if !FileManager.default.fileExists(atPath: "/Library/Developer/CommandLineTools") {
            return false
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
        let output = String(data: data, encoding: .utf8)!

        if output.contains("version: 15.") {
            return true
        } else {
            return false
        }
    }
}
