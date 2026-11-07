import Foundation

public struct DirectorySizer: Sendable {
    public init() {}

    /// Allocated size in bytes, using `du` so package bundles are measured fully.
    public func allocatedSize(at path: String) -> Int64? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/du")
        process.arguments = ["-sk", "--", path]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = output.fileHandleForReading.readDataToEndOfFile()
            guard let text = String(data: data, encoding: .utf8) else { return nil }
            guard let first = text.split(whereSeparator: { $0 == " " || $0 == "\t" || $0 == "\n" }).first else {
                return nil
            }
            guard let blocks = Int64(first) else { return nil }
            return blocks * 1024
        } catch {
            return nil
        }
    }
}
