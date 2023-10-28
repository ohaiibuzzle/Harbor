//
//  DXVKUtils.swift
//  Harbor
//
//  Created by Venti on 19/06/2023.
//

import Foundation
import Observation

struct DXUtils {
    static let shared = DXUtils()

    var DXVKLibsAvailable: Bool {
        let harborContainer = HarborUtils.shared.getContainerHome()
        let dxvkDirPath = harborContainer.appendingPathComponent("dxvk").appendingPathComponent("dxgi.dll")
        return FileManager.default.fileExists(atPath: dxvkDirPath.path)
    }

    var vulkanAvailable: Bool {
        // Check for the existance of /usr/local/opt/game-porting-toolkit/lib/wine/winevulkan.dll
        return FileManager.default
            .fileExists(atPath: "/usr/local/opt/game-porting-toolkit/lib/wine/x86_64-windows/winevulkan.dll")
    }

    func isDXVKAvailable() -> Bool {
        return DXVKLibsAvailable && vulkanAvailable
    }

    func untarDXVKLibs(dxvkZip: URL) {
        let dxvkPath = HarborUtils.shared.getContainerHome().appendingPathComponent("dxvk")
        if !FileManager.default.fileExists(atPath: dxvkPath.path) {
            do {
                try FileManager.default.createDirectory(at: dxvkPath,
                                                        withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Harbor: Failed to create Harbor home directory")
            }
        }

        // Untar the content of the x64 subdirectory under the tarball into the dxvk directory
        let task = Process()
        task.launchPath = "/usr/bin/tar"
        task.arguments = ["-xf", dxvkZip.path, "-C", dxvkPath.path, "--strip-components=2", "*/x64/*"]
        do {
            try task.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
        task.waitUntilExit()
    }

    func isWineD3DAvailable() -> Bool { // Unfortunately have to exist because previously we didn't save it
        let harborContainer = HarborUtils.shared.getContainerHome()
        let wined3dDirPath = harborContainer.appendingPathComponent("wined3d").appendingPathComponent("d3d11.dll")
        return FileManager.default.fileExists(atPath: wined3dDirPath.path)
    }
}
