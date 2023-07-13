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

        let gpkD3DLibInstalled = FileManager.default.fileExists(atPath: gpkD3DLib.path, isDirectory: isDir)
        let gpkWine64Installed = FileManager.default.fileExists(atPath: gpkWine64.path, isDirectory: isDir)

        self.status =
        switch (gpkD3DLibInstalled, gpkWine64Installed) {
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
        property shellScript : "clear && \(brewUtils.x64BrewPrefix)/bin/brew install \
        apple/apple/game-porting-toolkit && \
        clear && echo '\(String(localized: "setup.message.complete"))' && exit"

        tell application "Terminal"
            activate
            -- Enter x86_64 shell
            do script "arch -x86_64 /bin/sh"
            delay 2
            -- Install Homebrew
            do script shellScript in front window
        end tell
        """

        Task {
            if let script = NSAppleScript(source: aaplScript) {
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                if let error = error {
                    NSLog("Harbor: Failed to execute AppleScript: \(error)")
                }
            }
        }

        repeat {
            // Wait for GPK to be installed
            sleep(5)
            checkGPKInstallStatus()
        } while self.status == .notInstalled

        // Copy the GPK libraries
        copyGPKLibraries()
    }

    func fastInstallGPK(using brewUtils: BrewUtils, gpkBottle: URL) {
        // Abort if Brew is not installed
        brewUtils.testX64Brew()
        if brewUtils.installed == false {
            NSLog("Harbor: Brew not installed. Aborting")
            return
        }

        // Check if GPK bottle exists
        if !FileManager.default.fileExists(atPath: gpkBottle.path) {
            NSLog("Harbor: GPK bottle not found. Aborting")
            return
        }

        let aaplScript = """
        property shellScript : "clear && \(brewUtils.x64BrewPrefix)/bin/brew install gstreamer pkg-config zlib \
        freetype sdl2 libgphoto2 faudio jpeg libpng mpg123 libtiff libgsm glib gnutls libusb gettext molten-vk && \
        /usr/bin/xattr -r -d com.apple.quarantine \(gpkBottle.path) && \
        \(brewUtils.x64BrewPrefix)/bin/brew install --ignore-dependencies \(gpkBottle.path) && \
        clear && echo '\(String(localized: "setup.message.complete"))' && exit"

        tell application "Terminal"
            activate
            -- Enter x86_64 shell
            do script "arch -x86_64 /bin/sh"
            delay 2
            -- Install Homebrew
            do script shellScript in front window
        end tell
        """

        Task {
            if let script = NSAppleScript(source: aaplScript) {
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                if let error = error {
                    NSLog("Harbor: Failed to execute AppleScript: \(error)")
                }
            } else {
                return
            }
        }

        repeat {
            // Wait for GPK to be installed
            sleep(5)
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
            let gpkLibDest = URL(fileURLWithPath: "/usr/local/opt/game-porting-toolkit/lib")

            // Merge the content from /Volumes/Game Porting Toolkit*/lib to /usr/local/opt/game-porting-toolkit/lib
            let dittoProcess = Process()
            dittoProcess.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            dittoProcess.arguments = ["-V", gpkLib.path, gpkLibDest.path]
            dittoProcess.standardOutput = nil
            dittoProcess.standardError = nil
            do {
                try dittoProcess.run()
            } catch {
                HarborUtils.shared.quickError(error.localizedDescription)
            }
            dittoProcess.waitUntilExit()

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
            do {
                try hdiutil2.run()
            } catch {
                HarborUtils.shared.quickError(error.localizedDescription)
            }
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

    func reinstallGPKLibraries() {
        // Remove the GPK libraries
        let gpkLib = URL(fileURLWithPath: "/usr/local/opt/game-porting-toolkit/lib/external")
        if FileManager.default.fileExists(atPath: gpkLib.path) {
            do {
                try FileManager.default.removeItem(at: gpkLib)
            } catch {
                HarborUtils.shared.quickError(error.localizedDescription)
                return
            }
        }
        // Copy the GPK libraries
        copyGPKLibraries()
    }

    func completelyRemoveGPK() {
        // Remove the GPK bottle from Brew
        let aaplScript = """
        property shellScript : "clear && /usr/local/Homebrew/bin/brew uninstall game-porting-toolkit && \
        echo '\(String(localized: "setup.message.removalComplete"))' && exit"

        tell application "Terminal"
            activate
            -- Enter x86_64 shell
            do script "arch -x86_64 /bin/sh"
            delay 2
            -- Run removal
            do script shellScript in front window
        end tell
        """

        if let script = NSAppleScript(source: aaplScript) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let error = error {
                NSLog("Harbor: Failed to execute AppleScript: \(error)")
            } else {
                status = .notInstalled
            }
        } else {
            return
        }
    }
}
