//
//  MVKUtils.swift
//  Harbor
//
//  Created by Venti on 19/06/2023.
//

import Foundation

class BottleDXVK {
    static let shared = BottleDXVK()

    func checkBottleForDXVK(bottle: HarborBottle) -> Bool {
        let bottlePath = bottle.path
        let dxvkUniqueOverrides = ["dxgi", "d3d9", "d3d11"]
        for override in dxvkUniqueOverrides {
            let overridePath = bottlePath.appendingPathComponent("drive_c/windows/system32/\(override).dll.orig")
            if !FileManager.default.fileExists(atPath: overridePath.path) {
                return false
            }
        }
        return true
    }

    func installDXVKToBottle(bottle: HarborBottle) {
        if !DXVKUtils.shared.isDXVKAvailable() || checkBottleForDXVK(bottle: bottle) {
            return
        }
        let bottlePath = bottle.path
        let dxvkDirPath = HarborUtils.shared.getContainerHome().appendingPathComponent("dxvk")

        let dxvkOverrides = ["dxgi", "d3d9", "d3d10core", "d3d11"]
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
            bottle.directLaunchApplication("reg.exe", arguments: ["add",
                                                            #"HKEY_CURRENT_USER\Software\Wine\DllOverrides"#, "/v",
                                                            override, "/d", "native", "/f"], shouldWait: true)
        }
    }

    func removeDXVKFromBottle(bottle: HarborBottle) {
        if !checkBottleForDXVK(bottle: bottle) {
            return
        }

        let bottlePath = bottle.path

        let dxvkOverrides = ["dxgi", "d3d9", "d3d10core", "d3d11"]
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
            bottle.directLaunchApplication("reg.exe", arguments: ["delete",
                                                            #"HKEY_CURRENT_USER\Software\Wine\DllOverrides"#, "/v",
                                                                  override, "/f"], shouldWait: true)
        }
    }
}
