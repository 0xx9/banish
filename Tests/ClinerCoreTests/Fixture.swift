import Foundation
import XCTest
@testable import ClinerCore

struct Fixture {
    let root: URL

    init() throws {
        root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cliner-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    func destroy() {
        try? FileManager.default.removeItem(at: root)
    }

    func url(_ relative: String) -> URL {
        root.appendingPathComponent(relative)
    }

    func directory(_ relative: String) throws {
        try FileManager.default.createDirectory(at: url(relative), withIntermediateDirectories: true)
    }

    func file(_ relative: String, contents: Data = Data([1])) throws {
        let destination = url(relative)
        try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try contents.write(to: destination)
    }

    func plist(_ relative: String, _ object: [String: Any]) throws {
        let data = try PropertyListSerialization.data(fromPropertyList: object, format: .xml, options: 0)
        try file(relative, contents: data)
    }

    func plistApp(_ relative: String, _ info: [String: Any]) throws {
        try plist(relative + "/Contents/Info.plist", info)
    }
}
