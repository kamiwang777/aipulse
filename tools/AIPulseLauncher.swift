import AppKit
import Foundation

@discardableResult
func run(_ launchPath: String, _ arguments: [String] = []) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: launchPath)
    process.arguments = arguments

    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr

    try process.run()
    process.waitUntilExit()

    let out = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let err = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

    guard process.terminationStatus == 0 else {
        throw NSError(domain: "AIPulseLauncher", code: Int(process.terminationStatus), userInfo: [
            NSLocalizedDescriptionKey: err.isEmpty ? out : err
        ])
    }

    return out
}

let home = FileManager.default.homeDirectoryForCurrentUser.path
let repoPath = "\(home)/aipulse"
let pluginDir = "\(home)/.swiftbar-plugins"
let pluginPath = "\(pluginDir)/aipulse.1m.sh"
let repoPluginPath = "\(repoPath)/aipulse.1m.sh"
let configDir = "\(home)/.config/aipulse"
let configPath = "\(configDir)/config.sh"
let exampleConfigPath = "\(repoPath)/config.example.sh"

do {
    try run("/bin/mkdir", ["-p", pluginDir, configDir])

    if !FileManager.default.fileExists(atPath: pluginPath) {
        guard FileManager.default.fileExists(atPath: repoPluginPath) else {
            exit(1)
        }
        try run("/bin/cp", [repoPluginPath, pluginPath])
        try run("/bin/chmod", ["+x", pluginPath])
    }

    if !FileManager.default.fileExists(atPath: configPath),
       FileManager.default.fileExists(atPath: exampleConfigPath) {
        try run("/bin/cp", [exampleConfigPath, configPath])
    }

    let workspace = NSWorkspace.shared
    let configuration = NSWorkspace.OpenConfiguration()

    let userSwiftBarPath = "\(home)/Applications/SwiftBar.app"
    let systemSwiftBarPath = "/Applications/SwiftBar.app"

    if FileManager.default.fileExists(atPath: userSwiftBarPath) {
        let url = URL(fileURLWithPath: userSwiftBarPath)
        workspace.openApplication(at: url, configuration: configuration) { _, error in
            if let error {
                fputs("AIPulse Launcher error: \(error.localizedDescription)\n", stderr)
                exit(1)
            }
            exit(0)
        }
        RunLoop.current.run()
    } else if FileManager.default.fileExists(atPath: systemSwiftBarPath) {
        let url = URL(fileURLWithPath: systemSwiftBarPath)
        workspace.openApplication(at: url, configuration: configuration) { _, error in
            if let error {
                fputs("AIPulse Launcher error: \(error.localizedDescription)\n", stderr)
                exit(1)
            }
            exit(0)
        }
        RunLoop.current.run()
    } else {
        try run("/usr/bin/open", ["-a", "SwiftBar"])
    }
} catch {
    fputs("AIPulse Launcher error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
