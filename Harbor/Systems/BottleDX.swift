//
//  MVKUtils.swift
//  Harbor
//
//  Created by Venti on 19/06/2023.
//

import Foundation

enum DXBackend: String {
    case how = "did we get here?"
    case gptk = "GPTK"
    case dxvk = "DXVK"
    case wined3d = "WineD3D"
}

class BottleDX {
    static let shared = BottleDX()

    let dxvkOverrides = ["dxgi", "d3d9", "d3d10core", "d3d11"]
    let wined3dOverrides = ["dxgi", "d3d9", "d3d10", "d3d11", "d3d12"]

    func checkBottleBackend(for bottle: HarborBottle) -> DXBackend {
        let bottlePath = bottle.path
        // Check the backend.hrb file in the bottle's system32
        // If it doesn't exist -> GPTK
        // If it does exist -> check the contents (DXVK, WineD3D)
        let backendPath = bottlePath.appendingPathComponent("drive_c/windows/system32/backend.hrb")
        if FileManager.default.fileExists(atPath: backendPath.path) {
            do {
                let backendContents = try String(contentsOf: backendPath)
                if backendContents.contains("DXVK") {
                    return .dxvk
                } else if backendContents.contains("WineD3D") {
                    return .wined3d
                }
            } catch {
                HarborUtils.shared.quickError(error.localizedDescription)
            }
        }
        return .gptk
    }

    func updateDXBackend(for bottle: HarborBottle, using backend: DXBackend) {
        let bottlePath = bottle.path
        let backendKind = checkBottleBackend(for: bottle)
        if backendKind != .gptk {
            revertToGPTK(for: bottle)
        }
        switch backend {
        case .dxvk:
            installDXVK(for: bottle)
        case .wined3d:
            installWineD3D(for: bottle)
        default:
            return
        }
        // Create the backend.hrb file
        let backendPath = bottlePath.appendingPathComponent("drive_c/windows/system32/backend.hrb")
        do {
            try backend.rawValue.write(to: backendPath, atomically: true, encoding: .utf8)
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
    }

    func revertToGPTK(for bottle: HarborBottle) {
        let bottlePath = bottle.path
        let backendKind = checkBottleBackend(for: bottle)
        if backendKind == .gptk {
            return
        }
        switch backendKind {
        case .dxvk:
            removeDXVKFromBottle(bottle: bottle)
        case .wined3d:
            removeWineD3D(for: bottle)
        default:
            return
        }
        // Remove the backend.hrb file
        let backendPath = bottlePath.appendingPathComponent("drive_c/windows/system32/backend.hrb")
        if FileManager.default.fileExists(atPath: backendPath.path) {
            do {
                try FileManager.default.removeItem(at: backendPath)
            } catch {
                HarborUtils.shared.quickError(error.localizedDescription)
            }
        }
    }

    func installDXVK(for bottle: HarborBottle) {
        if !DXUtils.shared.isDXVKAvailable() {
            return
        }

        let bottlePath = bottle.path
        let dxvkDirPath = HarborUtils.shared.getContainerHome().appendingPathComponent("dxvk")

        for override in dxvkOverrides {
            let overridePath = bottlePath.appendingPathComponent("drive_c/windows/system32/\(override).dll")
            // rename the original dll to .orig
            if FileManager.default.fileExists(atPath: overridePath.path) {
                do {
                    try FileManager.default.moveItem(at: overridePath, to: overridePath.appendingPathExtension("orig"))
                } catch {
                    HarborUtils.shared.quickError(error.localizedDescription)
                }
            }
            // symlink the dxvk dll
            let dxvkOverridePath = dxvkDirPath.appendingPathComponent("\(override).dll")
            do {
                try FileManager.default.createSymbolicLink(at: overridePath, withDestinationURL: dxvkOverridePath)
            } catch {
                HarborUtils.shared.quickError(error.localizedDescription)
            }
        }

        // Add override to wine registry
        for override in dxvkOverrides {
            applyRegistryOverrides(in: bottle, for: override)
        }
    }

    func removeDXVKFromBottle(bottle: HarborBottle) {
        let bottlePath = bottle.path
        
        for override in dxvkOverrides {
            let overridePath = bottlePath.appendingPathComponent("drive_c/windows/system32/\(override).dll")
            // remove the symlink
            if FileManager.default.fileExists(atPath: overridePath.path) {
                do {
                    try FileManager.default.removeItem(at: overridePath)
                } catch {
                    HarborUtils.shared.quickError(error.localizedDescription)
                }
            }
            // rename the original dll back
            let overrideOrigPath = overridePath.appendingPathExtension("orig")
            if FileManager.default.fileExists(atPath: overrideOrigPath.path) {
                do {
                    try FileManager.default.moveItem(at: overrideOrigPath, to: overridePath)
                } catch {
                    HarborUtils.shared.quickError(error.localizedDescription)
                }
            }
        }

        // Remove override from wine registry
        for override in dxvkOverrides {
            removeRegistryOverrides(in: bottle, for: override)
        }
    }

    func installWineD3D(for bottle: HarborBottle) {
        let bottlePath = bottle.path
        let wined3dDirPath = HarborUtils.shared.getContainerHome().appendingPathComponent("wined3d")

        for override in wined3dOverrides {
            let overridePath = bottlePath.appendingPathComponent("drive_c/windows/system32/\(override).dll")
            // rename the original dll to .orig
            if FileManager.default.fileExists(atPath: overridePath.path) {
                do {
                    try FileManager.default.moveItem(at: overridePath, to: overridePath.appendingPathExtension("orig"))
                } catch {
                    HarborUtils.shared.quickError(error.localizedDescription)
                }
            }
            // symlink the wined3d dll
            let wined3dOverridePath = wined3dDirPath.appendingPathComponent("\(override).dll")
            do {
                try FileManager.default.createSymbolicLink(at: overridePath, withDestinationURL: wined3dOverridePath)
            } catch {
                HarborUtils.shared.quickError(error.localizedDescription)
            }
        }

        // Add override to wine registry
        for override in wined3dOverrides {
            applyRegistryOverrides(in: bottle, for: override)
        }
    }

    func removeWineD3D(for bottle: HarborBottle) {
        let bottlePath = bottle.path

        for override in wined3dOverrides {
            let overridePath = bottlePath.appendingPathComponent("drive_c/windows/system32/\(override).dll")
            // remove the symlink
            if FileManager.default.fileExists(atPath: overridePath.path) {
                do {
                    try FileManager.default.removeItem(at: overridePath)
                } catch {
                    HarborUtils.shared.quickError(error.localizedDescription)
                }
            }
            // rename the original dll back
            let overrideOrigPath = overridePath.appendingPathExtension("orig")
            if FileManager.default.fileExists(atPath: overrideOrigPath.path) {
                do {
                    try FileManager.default.moveItem(at: overrideOrigPath, to: overridePath)
                } catch {
                    HarborUtils.shared.quickError(error.localizedDescription)
                }
            }
        }

        // Remove override from wine registry
        for override in wined3dOverrides {
            removeRegistryOverrides(in: bottle, for: override)
        }
    }

    func applyRegistryOverrides(in bottle: HarborBottle, for dll: String) {
        bottle.directLaunchApplication("reg.exe", arguments: ["add",
                                                        #"HKEY_CURRENT_USER\Software\Wine\DllOverrides"#, "/v",
                                                              dll, "/d", "native", "/f"], shouldWait: true)
    }

    func removeRegistryOverrides(in bottle: HarborBottle, for dll: String) {
        bottle.directLaunchApplication("reg.exe", arguments: ["delete",
                                                        #"HKEY_CURRENT_USER\Software\Wine\DllOverrides"#, "/v",
                                                              dll, "/f"], shouldWait: true)
    }
}
