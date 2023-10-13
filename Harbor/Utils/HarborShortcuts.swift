//
//  URIHandler.swift
//  Harbor
//
//  Created by Venti on 27/06/2023.
//

import Foundation
import AppKit

struct HarborShortcuts {
    static let shared = HarborShortcuts()

    func generateAppleScriptLauncher(bottle: HarborBottle) -> String {
        let wine64Path = "/usr/local/opt/game-porting-toolkit/bin/wine64"

        var shellScript = ""

        shellScript += "WINEPREFIX='\(bottle.path.path)'"
        if bottle.enableHUD {
            shellScript += " MTL_HUD_ENABLED=1"
        }
        switch bottle.syncPrimitives {
        case .none:
            break
        case .eSync:
            shellScript += " WINEESYNC=1"
        case .mSync:
            shellScript += " WINEMSYNC=1"
        }

        if !bottle.envVars.isEmpty {
            for (key, value) in bottle.envVars {
                shellScript += " \(key)='\(value)'"
            }
        }

        shellScript += " '\(wine64Path)' start"

        if !bottle.primaryApplicationWorkDir.isEmpty {
            shellScript += " /d '\(bottle.primaryApplicationWorkDir)'"
        }

        if !bottle.primaryApplicationPath.isEmpty {
            shellScript += " '\(bottle.primaryApplicationPath)'"
        }

        if !bottle.primaryApplicationArgument.isEmpty {
            shellScript += " \(bottle.primaryApplicationArgument)"
        }

        shellScript = shellScript.replacingOccurrences(of: "\\", with: "\\\\")
        shellScript = shellScript.replacingOccurrences(of: "\"", with: "\\\"")

        let aaplScript = """
        do shell script "\(shellScript)"
        """

        return aaplScript
    }

    func createDesktopShortcut(for bottle: HarborBottle) {
        let aaplScript = generateAppleScriptLauncher(bottle: bottle)

        let tempDir = FileManager.default.temporaryDirectory
        guard let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }
        let scriptFile = tempDir.appendingPathComponent("launch.scpt")
        let appFile = desktopPath.appendingPathComponent("\(bottle.name).app")

        do {
            try aaplScript.write(to: scriptFile, atomically: true, encoding: .utf8)
            let compileProcess = Process()
            compileProcess.launchPath = "/usr/bin/osacompile"
            compileProcess.arguments = ["-o", appFile.path, scriptFile.path]
            try compileProcess.run()
            compileProcess.waitUntilExit()

            if compileProcess.terminationStatus != 0 {
                NSLog("Failed to compile AppleScript")
                return
            }

            // Replace the applet.icns with BottleIcon.icns from the assets
            if let iconFile = Bundle.main.url(forResource: "BottleIcon", withExtension: "icns") {
                let iconDestination = appFile.appendingPathComponent("Contents/Resources/applet.icns")
                try FileManager.default.removeItem(at: iconDestination)
                try FileManager.default.copyItem(at: iconFile, to: iconDestination)
            }

            // Remove the temporary files
            try FileManager.default.removeItem(at: scriptFile)

            let alert = NSAlert()
            alert.messageText = String(localized: "desktopShortcutCreated.title \(bottle.name)")
            alert.informativeText = String(localized: "desktopShortcutCreated.message \(bottle.name)")
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
    }
}
