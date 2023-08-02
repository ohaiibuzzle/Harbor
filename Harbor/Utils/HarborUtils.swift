//
//  CommonUtils.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import Foundation
import AppKit

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
                try FileManager.default.createDirectory(at: harborHome,
                                                        withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Harbor: Failed to create Harbor home directory")
            }
        }
        return harborHome
    }

    func quickError(_ errorMessage: String) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = String(localized: "harbor.errorAlert")
        alert.informativeText = errorMessage
        alert.runModal()
    }

    func dropNukeOnWine() {
        // SIGKILL any `wineserver` processes
        var task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["-9", "wineserver"]
        do {
            try task.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
        task.waitUntilExit()

        task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["-9", "wine64-preloader"]
        do {
            try task.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
        task.waitUntilExit()
    }

    func wipeShaderCache() {
        // cd $(getconf DARWIN_USER_CACHE_DIR)/d3dm
        let getconf = Process()
        getconf.executableURL = URL(fileURLWithPath: "/usr/bin/getconf")
        getconf.arguments = ["DARWIN_USER_CACHE_DIR"]
        let pipe = Pipe()
        getconf.standardOutput = pipe
        do {
            try getconf.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
        getconf.waitUntilExit()

        let getconfOutput = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let getconfOutputString = String(data: getconfOutput, encoding: .utf8) else {
            return
        }

        let d3dmPath = URL(fileURLWithPath: getconfOutputString.trimmingCharacters(in: .whitespacesAndNewlines))
            .appendingPathComponent("d3dm").path
        do {
            try FileManager.default.removeItem(atPath: d3dmPath)
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
    }
}
