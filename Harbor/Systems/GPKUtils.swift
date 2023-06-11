//
//  GPKStatus.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import Foundation
import AppKit
import Observation

enum GPKStatus {
    case notInstalled
    case partiallyInstalled
    case installed
}

@Observable
final class GPKUtils {
    var status: GPKStatus = .notInstalled

    init() {
        checkGPKInstallStatus()
    }

    func checkGPKInstallStatus() {
        let isDir = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        isDir.initialize(to: false)
        defer { isDir.deallocate() }

        // Check if /usr/local/opt/game-porting-toolkit/bin/wine64 has existed
        let gpkD3DLib = URL(fileURLWithPath: "/usr/local/opt/game-porting-toolkit/lib/external/libd3dshared.dylib")
        let gpkWine64 = URL(fileURLWithPath: "/usr/local/opt/game-porting-toolkit/bin/wine64")

        let gpkD3DLinInstalled = FileManager.default.fileExists(atPath: gpkD3DLib.path, isDirectory: isDir)
        let gpkWine64Installed = FileManager.default.fileExists(atPath: gpkWine64.path, isDirectory: isDir)

        self.status =
        switch (gpkD3DLinInstalled, gpkWine64Installed) {
        case (true, true):
                .installed
        case (false, false):
                .notInstalled
        default:
                .partiallyInstalled
        }
    }

    func installGPK(using brewUtils: BrewUtils) {
        // Abort if Brew is not installed
        brewUtils.testX64Brew()
        if brewUtils.installed == false {
            NSLog("Harbor: Brew not installed. Aborting")
            return
        }

        let aaplScript = """
        property shellScript : "\(brewUtils.x64BrewPrefix)/bin/brew install apple/apple/game-porting-toolkit && \
        clear && echo 'Game Porting Toolkit has been installed. You can now close this Terminal window.' && exit"

        tell application "Terminal"
            activate
            -- Enter x86_64 shell
            do script "arch -x86_64 /bin/sh"
            -- Install Homebrew
            do script shellScript in front window
        end tell
        """

        Task {
            let script = NSAppleScript(source: aaplScript)!
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let error = error {
                NSLog("Harbor: Failed to execute AppleScript: \(error)")
            }
        }

        repeat {
            // Wait for GPK to be installed
            sleep(1)
            checkGPKInstallStatus()
        } while self.status == .notInstalled

        // Copy the GPK libraries
        copyGPKLibraries()
    }

    func copyGPKLibraries() {
        // Mounts the GPK disk image
        let harborContainer = HarborUtils.shared.getContainerHome()
        let gpkDMG = harborContainer.appendingPathComponent("GPK.dmg")
        // final sanity check, and then copy everything from /lib inside the image
        // to /usr/local/opt/game-porting-toolkit/lib
        if FileManager.default.fileExists(atPath: gpkDMG.path) {
            // launch hdiutil to mount the image
            let hdiutil = Process()
            hdiutil.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            hdiutil.arguments = ["attach", gpkDMG.path]
            hdiutil.launch()
            hdiutil.waitUntilExit()

            // Get the mounted volume name (starts with Game Porting Toolkit)
            guard let mountedVolume = try? FileManager.default.contentsOfDirectory(atPath: "/Volumes")
                .first(where: { $0.starts(with: "Game Porting Toolkit") })
            else {
                NSLog("Harbor: Failed to find mounted GPK disk image")
                return
            }
            let gpkVolume = URL(fileURLWithPath: "/Volumes/\(mountedVolume)")
            let gpkLib = gpkVolume.appendingPathComponent("lib")
            let gpkLibDest = URL(fileURLWithPath: "/usr/local/opt/game-porting-toolkit/")

            // Merge the content from /Volumes/Game Porting Toolkit*/lib to /usr/local/opt/game-porting-toolkit/lib
            let cpProcess = Process()
            cpProcess.executableURL = URL(fileURLWithPath: "/bin/cp")
            cpProcess.arguments = ["-R", gpkLib.path, gpkLibDest.path]
            cpProcess.standardOutput = nil
            cpProcess.standardError = nil
            cpProcess.launch()
            cpProcess.waitUntilExit()

            // Copy all the gameportingtoolkit* binaries to Harbor's container (for later use)
            let harborContainer = HarborUtils.shared.getContainerHome()
            let gpkBinDest = harborContainer.appendingPathComponent("bin")
            if FileManager.default.fileExists(atPath: gpkBinDest.path) == false {
                try? FileManager.default.createDirectory(at: gpkBinDest,
                                                         withIntermediateDirectories: true, attributes: nil)
            }

            // Unmount the image
            let hdiutil2 = Process()
            hdiutil2.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            hdiutil2.arguments = ["detach", gpkVolume.path]
            hdiutil2.launch()
            hdiutil2.waitUntilExit()
        } else {
            NSLog("Harbor: GPK disk image not found. Aborting")
        }
    }

    func showGPKInstallAlert() -> Bool {
        // Popup an alert warning the user about the GPK installation process
        let alert = NSAlert()
        alert.messageText = String(localized: "alert.GPKInstall.title")
        alert.informativeText = String(localized: "alert.GPKInstall.informativeText")
        alert.alertStyle = .warning
        alert.addButton(withTitle: String(localized: "btn.OK"))
        alert.addButton(withTitle: String(localized: "btn.cancel"))

        if alert.runModal() == .alertFirstButtonReturn {
            // User clicked OK. Go time.
            return true
        } else {
            // User clicked Cancel
            return false
        }
    }
}