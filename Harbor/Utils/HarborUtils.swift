//
//  CommonUtils.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import Foundation

struct HarborUtils {
    static let shared = HarborUtils()

    func getContainerHome() -> URL {
        // Since we are running without App Sandbox, we start at Home...
        // So we create our own
        let home = FileManager.default.homeDirectoryForCurrentUser
        let harborHome = home.appendingPathComponent("Library/Containers/dev.ohaiibuzzle.Harbor/Data")
        // Create it if needed
        if !FileManager.default.fileExists(atPath: harborHome.path) {
            do {
                try FileManager.default.createDirectory(at: harborHome, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Harbor: Failed to create Harbor home directory")
            }
        }
        return harborHome
    }
}
