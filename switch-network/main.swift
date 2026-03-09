import Foundation
import SystemConfiguration

let watchedKey = "State:/Users/ConsoleUser" as CFString
let scriptPath = "/opt/switch-network/switch_network_order_by_user.sh"

func runScript() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = [scriptPath]

    let outPipe = Pipe()
    let errPipe = Pipe()
    process.standardOutput = outPipe
    process.standardError = errPipe

    do {
        try process.run()
        process.waitUntilExit()

        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

        if let out = String(data: outData, encoding: .utf8), !out.isEmpty {
            NSLog("script stdout: \(out)")
        }
        if let err = String(data: errData, encoding: .utf8), !err.isEmpty {
            NSLog("script stderr: \(err)")
        }
    } catch {
        NSLog("failed to run script: \(error)")
    }
}

func callback(
    store: SCDynamicStore,
    changedKeys: CFArray?,
    info: UnsafeMutableRawPointer?
) {
    NSLog("ConsoleUser changed, running network switch script")
    runScript()
}

var context = SCDynamicStoreContext(
    version: 0,
    info: nil,
    retain: nil,
    release: nil,
    copyDescription: nil
)

guard let store = SCDynamicStoreCreate(
    nil,
    "local.consoleuser.listener" as CFString,
    callback,
    &context
) else {
    fatalError("Unable to create SCDynamicStore")
}

guard SCDynamicStoreSetNotificationKeys(store, [watchedKey] as CFArray, nil) else {
    fatalError("Unable to subscribe to ConsoleUser changes")
}

if let runLoopSource = SCDynamicStoreCreateRunLoopSource(nil, store, 0) {
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)
} else {
    fatalError("Unable to create runloop source")
}

// 启动时先执行一次，避免系统启动后顺序不一致
runScript()

NSLog("ConsoleUser listener started")
CFRunLoopRun()
